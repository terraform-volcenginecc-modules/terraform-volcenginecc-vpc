# terraform-volcenginecc-vpc

基于 `volcenginecc` Provider 的 Terraform 模块，用于创建火山引擎 VPC，或读取一个显式指定的既有 VPC。

## 1. 概述

本模块仅管理 VPC 边界。它有意不创建子网、路由表、安全组、NAT 网关、EIP、互联网网关、流日志或 PrivateLink 终端节点。这些资源应通过其他模块、利用 `vpc_id` 输出来组合编排。

本模块支持两种归属模式：

- 创建模式（`create_vpc = true`）：创建并拥有一个 `volcenginecc_vpc_vpc`。
- 既有模式（`create_vpc = false`）：通过数据源读取 `existing_vpc_id`，不拥有也不销毁该 VPC。

切勿原地切换 `create_vpc`。从创建模式切到既有模式可能销毁已纳管的 VPC，而反向切换则会新建一个 VPC。应改用新的模块地址，或经过评审的 Terraform 状态/import 迁移。

## 2. 用法

### 2.1 创建 VPC

```hcl
module "vpc" {
  source  = "terraform-volcenginecc-modules/vpc/volcenginecc"
  version = "~> 1.0"

  name       = "example-vpc"
  cidr_block = "10.10.0.0/16"
  enable_ipv6 = true

  tags = {
    Environment = "development"
    ManagedBy   = "Terraform"
  }
}
```

Provider 认证与地域配置应由调用方负责：

```hcl
provider "volcenginecc" {
  region = "cn-beijing"
}
```

请使用环境变量、profile 或其他支持的凭证来源。不要把访问密钥写入模块配置中。

### 2.2 已有 VPC

```hcl
module "vpc" {
  source  = "terraform-volcenginecc-modules/vpc/volcenginecc"
  version = "~> 1.0"

  create_vpc      = false
  existing_vpc_id = "vpc-xxxxxxxx"
}
```

在既有模式下，创建相关输入必须保持未设置。这样可以避免配置看似被接受、实则被静默忽略。

## 3. 示例

- basic：创建一个最小化的 IPv4 VPC。
- complete：覆盖 VPC 模块的全部稳定输入。
- secondary-cidr-blocks：单独验证辅助 CIDR 行为。
- existing-vpc：读取一个显式指定的 VPC，不接管其归属。
- ipv6-dualstack：创建一个 IPv4/IPv6 双栈 VPC，并自动分配 IPv6 CIDR。

## 4. 版本要求

| 名称 | 版本 |
|---|---|
| Terraform | `>= 1.5.0` |
| `volcengine/volcenginecc` | `>= 0.0.60` |

## 5. Provider

| 名称 | 来源 |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. 资源

| 模式 | 类型 | 名称 |
|---|---|---|
| 创建 | Resource | `volcenginecc_vpc_vpc.this` |
| 既有 | Data Source | `volcenginecc_vpc_vpc.existing` |

## 7. 输入

| 名称 | 类型 | 默认值 | 创建模式下是否必填 | 说明 |
|---|---|---:|---:|---|
| `create_vpc` | `bool` | `true` | 否 | 选择创建或既有模式。切勿原地切换。 |
| `existing_vpc_id` | `string` | `null` | 否 | 在既有模式下必填。 |
| `name` | `string` | `null` | 是 | VPC 名称。 |
| `cidr_block` | `string` | `null` | 是 | 规范的私有 IPv4 CIDR。修改它会替换 VPC。 |
| `description` | `string` | `null` | 否 | VPC 描述。 |
| `dns_servers` | `set(string)` | `null` | 否 | 设置时为 1 到 5 个 DNS 服务器 IP 地址。 |
| `secondary_cidr_blocks` | `set(string)` | `null` | 否 | 设置时恰为一个辅助 IPv4 CIDR，且与主 CIDR 同属一个私有地址范围。 |
| `user_cidr_blocks` | `set(string)` | `null` | 否 | 设置时为非空的用户 IPv4 CIDR。 |
| `enable_ipv6` | `bool` | `null` | 否 | 在创建时启用自动 IPv6 CIDR 分配。切勿原地切换。 |
| `project_name` | `string` | `null` | 否 | 项目名称。修改它会替换 VPC。 |
| `tags` | `map(string)` | `null` | 否 | 设置时为非空的 VPC 标签。 |

## 8. 输出

| 名称 | 类型 | 说明 |
|---|---|---|
| `vpc_id` | `string` | 已创建或既有 VPC 的 ID。 |
| `vpc_name` | `string` | VPC 名称。 |
| `cidr_block` | `string` | 主 IPv4 CIDR。 |
| `secondary_cidr_blocks` | `set(string)` | 辅助 IPv4 CIDR。 |
| `user_cidr_blocks` | `set(string)` | 用户 IPv4 CIDR。 |
| `enable_ipv6` | `bool` | 是否报告了非空的 IPv6 CIDR。 |
| `ipv6_cidr_block` | `string` | 自动分配的 IPv6 CIDR；禁用时为空值。 |
| `project_name` | `string` | 项目名称。 |
| `support_ipv4_gateway` | `bool` | Provider 只读报告的 IPv4 网关支持情况。 |
| `ipv4_gateway_id` | `string` | 只读报告的已绑定 IPv4 网关 ID，或为空值。 |
| `tags` | `map(string)` | 从 Provider 表示规范化后的标签。 |
| `route_table_ids` | `set(string)` | 只读报告的路由表关联。这并不意味着归属。 |
| `is_default` | `bool` | 该 VPC 是否为默认 VPC。 |
| `status` | `string` | Provider 报告的 VPC 状态。 |

## 9. 其他说明

- `cidr_block` 与 `project_name` 是仅创建时可用的 Provider 字段。修改其中任意一个都会替换 VPC。
- 本模块不会自动发现默认 VPC，因为当前的复数 VPC 数据源无法按 `is_default` 过滤。
- `enable_ipv6 = true` 已在创建、刷新、第二次无变更 Plan、既有 VPC 读取以及销毁等环节验证。该 Provider 字段只写；原地切换虽能成功，但紧随其后的 Plan 会包含一次仅刷新性质的 IPv6 CIDR 输出变更。应将其视为创建时设置。
- 本模块未暴露自定义 IPv6 CIDR 输入，因为在账号自有前缀下无法安全验证新增/修改/删除。
- IPv4 网关在本模块中有意设为只读。在创建 VPC 时提供 `support_ipv_4_gateway` 和一个未绑定的 `ipv_4_gateway_id`，并不会附加或启用网关。必须通过原生 API 流程先创建网关、将其绑定到 VPC、添加一条 `Ipv4GW` 默认路由并启用它，Provider 才能回读到已配置的值。
- 本模块会校验 CIDR 语法、文档所列私有地址范围、辅助 CIDR 数量配额（仅一个），以及主/辅助 CIDR 是否同属一个私有地址范围。云端的重叠规则仍然适用。
- 对于 `dns_servers`、`secondary_cidr_blocks`、`user_cidr_blocks` 和 `tags`，使用 `null` 表示不指定该设置，使用非空集合表示由本模块管理。空集合会被拒绝，因为 Provider v0.0.60 会把它们回读为 `null`，否则会造成永久的 plan 差异。将已纳管的非空集合改为 `null` 只是不再声明它，并不会清除云端的值。
- `route_table_ids` 仅供诊断的只读信息。本模块不拥有这些路由表。
- apply 之后必须再执行一次 `terraform plan`；只有当第二次 plan 报告无变更时，发布才可接受。
