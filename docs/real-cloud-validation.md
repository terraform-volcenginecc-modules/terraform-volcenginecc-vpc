# 真实云环境验收报告

## 验收结论

2026-08-02，Module 已通过下表所列的 IPv4 与 IPv6 真实云环境场景。IPv4 Gateway 的完整原生 API 生命周期也已完成验证，但该能力不能由当前 Provider 的 VPC Resource 独立编排。由于 Provider `0.0.60` 在清空集合字段后仍无法得到幂等 Plan，当前结果**尚未满足建设方案中的完整发布门禁**。

- 地域：`cn-beijing`
- Terraform：`1.15.4`
- Provider：`volcengine/volcenginecc` `0.0.60`
- 运行标识：`vpcmod-20260802095432`、`vpcmod-clean-20260802`、`vpcmod-ip-20260802-ip01`、`vpcmod-ipv4gw-20260802223215`
- 认证方式：读取 `~/.volcengine/config.json` 当前选中的 Profile；没有向本仓库写入凭证
- 清理结果：5 个测试 VPC 均已销毁；本轮 IPv4 Gateway、默认路由、关联关系也已删除；最终 Terraform State 中的资源数量均为 0；原 Gateway ID 查询结果为空

## 保留的测试资产

- 可复跑测试配置：[`../tests/`](../tests/)
- 原始 State、Plan、Lock 文件和 Provider 缓存：仅保留在本地审计目录，不纳入本仓库版本控制

可复跑目录的 Git 提交内容不包含凭证、State、Plan、Lock 文件或 Provider 缓存；这些本地运行产物由 `.gitignore` 排除。

## 已验证场景

| 场景 | 验收证据 |
|---|---|
| 基础创建 | Plan 显示 `1 to add`；Apply 成功创建一个 VPC，并返回 VPC ID 和主 CIDR。 |
| 创建后幂等性 | 创建后立即再次执行 Plan，结果为 `No changes`，详细退出码为 `0`。 |
| 原地更新 | 成功更新名称、描述、DNS、Tags 和 User CIDR，VPC ID 保持不变，未替换 VPC。 |
| 更新后幂等性 | 更新后再次执行 Plan，结果为 `No changes`；State 中的字段值与输入值一致。 |
| 辅助 CIDR | 成功添加一个与主 CIDR 属于同一私网大段且不重叠的辅助 CIDR；后续 Plan 为 `No changes`。 |
| Complete 示例 | 成功创建包含描述、辅助 CIDR、User CIDR、默认项目、Tags 和只读 Outputs 的 VPC；状态为 `Available`；后续 Plan 为 `No changes`。 |
| Existing VPC 模式 | 使用独立 State 读取已创建的 VPC，Outputs 与创建模式一致，后续 Plan 为 `No changes`；销毁该 State 时显示 `0 destroyed`，创建模式的 VPC 仍然存在。 |
| IPv6 双栈创建 | `enable_ipv6=true` 创建成功；IPv4 CIDR 为 `10.235.0.0/16`，云端自动分配 `/56` IPv6 CIDR，VPC 状态为 `Available`。 |
| IPv6 创建后幂等性 | 刷新后 Module 的第二次 Plan 为 `No changes`，详细退出码为 `0`。 |
| IPv6 Existing VPC | 独立 State 能回读非空 IPv6 CIDR；Module 根据 CIDR 归一化 `enable_ipv6=true`，第二次 Plan 退出码为 `0`。 |
| IPv6 开关切换 | `true -> false` 与 `false -> true` 均原地更新成功，VPC ID 不变；但紧接 Apply 的第一次 Plan 会发现 IPv6 CIDR Output 的刷新变化，应用该刷新结果后下一次 Plan 才为 `No changes`。因此仅承诺创建时设置。 |
| IPv4 Gateway：仅开关 | 只传 `support_ipv_4_gateway=true` 时，VPC 创建成功，但没有实际 Gateway，回读为 `false` 和空 ID，第二次 Plan 要求替换 VPC。 |
| IPv4 Gateway：传真实 ID | 使用原生 SDK 创建未关联 Gateway，并同时向 VPC 传入 `support_ipv_4_gateway=true` 和真实 `ipv_4_gateway_id`；VPC 创建仍未自动关联或启用 Gateway，原生查询显示 `VpcId=""`、`Enabled=false`，第二次 Plan 仍要求替换。 |
| IPv4 Gateway：完整配置 | 原生 API 依次执行 `AttachIpv4Gateway`、创建 `0.0.0.0/0 -> Ipv4GW` 路由、`EnableIpv4Gateway` 后，Gateway 返回正确 VPC ID 且 `Enabled=true`；Terraform 刷新后回读正确 Gateway ID 与开关，第二次 Plan 为 `No changes`，详细退出码为 `0`。 |
| IPv4 Gateway：清理 | 原生 API 依次停用 Gateway、删除默认路由、解除 VPC 关联；Terraform 销毁 VPC 后删除 Gateway。最终 State 数量为 `0`，按 Gateway ID 查询结果为空。 |
| 不存在的 VPC | 查询不存在的 VPC ID 时返回 `Data Source Not Found`，且没有创建任何资源。 |
| Create-only 主 CIDR | 修改 `cidr_block` 后，Plan 显示 `delete, create` 替换动作；仅检查了替换 Plan，没有实际执行替换。 |
| 最终销毁 | 5 个测试 VPC 均已销毁；State 中资源数量为 0；本轮原生 Gateway 按 ID 查询结果为空。 |

## 验收过程中发现并修复的问题

### 辅助 CIDR 示例不合法

原示例将属于 `10.0.0.0/8` 的主 CIDR 与属于 `172.16.0.0/12` 或 `192.168.0.0/16` 的辅助 CIDR 组合使用，云端 API 返回 `InvalidCidr.Malformed`。

火山引擎要求辅助 IPv4 CIDR 与主 CIDR 属于同一个私网大段、彼此不能重叠，并且单个 VPC 最多只能配置一个辅助 IPv4 CIDR。现已修正相关示例，并在 Module 中增加以下校验：

- 配置辅助 CIDR 时必须恰好提供一个 CIDR。
- 辅助 CIDR 必须是规范的私网 IPv4 CIDR。
- 主 CIDR 与辅助 CIDR 必须属于同一个私网大段。
- CIDR 重叠仍由云端 API 进行最终校验。

### 空集合导致永久差异

Provider `0.0.60` 会把已经清空的集合和 Tags 列表回读为 `null`。因此，配置中显式传入空集合后，下一次 Plan 仍会尝试再次写入空集合，无法得到 `No changes`。

Module 现在拒绝为以下参数传入空集合：

- `dns_servers`
- `secondary_cidr_blocks`
- `user_cidr_blocks`
- `tags`

使用 `null` 表示不声明该配置，使用非空集合表示由 Module 管理该配置。将一个已经管理的非空集合改成 `null`，只会停止声明该字段，不会清除云端已经存在的值。

这仍然是原建设方案中的发布阻断项。原方案要求集合字段在添加、修改、删除和清空后都能重新得到 `No changes`。发布前必须完成以下方案之一：

1. 修复 Provider 的空集合与 `null` 状态归一问题。
2. 经过评审，正式缩小稳定版 Module 的接口和验收范围，明确不支持集合字段清空。

## 尚未完成的边界验证

- 显式 IPv6 CIDR 的添加、修改和移除尚未验证。测试账号没有选定可安全使用的自有 IPv6 前缀，因此 Module 只暴露自动分配开关，不暴露自定义 IPv6 CIDR 输入。
- IPv4 Gateway 已完成完整 Spike。当前 Provider 没有独立 IPv4 Gateway Resource，且 VPC Resource 不会编排关联、默认路由和启用操作，因此不能作为 VPC Module 的自包含可写能力。复现配置与原生 SDK 工具保留在 [`../tests/ipv4-gateway/`](../tests/ipv4-gateway/)。
- 未实际执行非默认 `project_name` 的替换，因为本次没有选定可安全销毁的测试项目；主 CIDR 替换 Plan 已验证相同的 Create-only 生命周期机制。
- 没有记录 `create_vpc=true -> false` 和 `false -> true` 两种所有权模式切换 Plan；调用方仍应使用新的 Module 地址，或者执行经过评审的 State/Import 迁移。
- 本次从 Registry 解析到的最新 Provider 版本仍为 `0.0.60`，因此最低版本和最新版本验证实际使用的是同一个 Provider 二进制文件。
