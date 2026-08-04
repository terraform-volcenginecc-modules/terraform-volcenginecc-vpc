# 真实云环境测试目录

本目录保留 `terraform-volcenginecc-vpc` 的可复跑真实云测试配置。版本控制只保留测试配置和辅助脚本；本地运行生成的 Terraform State、Plan、Lock 文件和 Provider 缓存均由 `.gitignore` 排除，不应提交到远端仓库。

## 测试内容

- `lifecycle/`：使用同一个 Terraform State 验证创建、二次 Plan、原地更新、再次 Plan 和销毁。
- `existing-vpc/`：使用独立 Terraform State 验证读取已有 VPC，以及 Destroy 不删除该 VPC。
- `ip-stack/`：通过 Module 专项验证 IPv6 创建、开关切换、回读和幂等性。
- `ipv4-gateway/`：通过 Terraform + 原生 Go SDK验证 IPv4 Gateway 的创建、关联、默认路由、启用、回读、幂等和清理；该能力因无法由 VPC Resource 自包含编排而未进入 Module 可写接口。
- `load-current-profile.sh`：安全读取 `~/.volcengine/config.json` 当前 Profile 并导出 Provider 环境变量，不输出 AK/SK。
- `validate.sh`：在临时目录中执行格式和静态校验，不创建云资源。

## 前置检查

这些命令会创建和销毁真实云资源。所有测试夹具都在 Provider 配置中显式使用 `region` 变量，默认值为 `cn-beijing`；凭证仍由 Provider 默认凭证链读取，不写入测试配置。

```bash
cd tests
./validate.sh
```

如需覆盖默认地域，在 Terraform 命令中增加 `-var="region=目标地域"`。`load-current-profile.sh` 仅作为显式导出环境变量凭证的可选工具，不再是运行测试的必要步骤。

## 创建与幂等验证

设置本次运行的唯一后缀：

```bash
export VPC_TEST_RUN_ID="$(date +%Y%m%d%H%M%S)"
```

每个测试目录使用本地 State。开始新的 Run 前必须确认 `lifecycle/` 没有上一次测试遗留的资源：

```bash
terraform -chdir=lifecycle init
terraform -chdir=lifecycle state list
```

`state list` 必须没有任何输出才能继续。不要在同一个非空 State 中只更换 `VPC_TEST_RUN_ID`，这会更新原 VPC，而不是创建独立的新测试资源。

创建 VPC：

```bash
terraform -chdir=lifecycle apply \
  -var="run_id=${VPC_TEST_RUN_ID}" \
  -var="phase=create"
```

创建完成后立即执行第二次 Plan，预期为 `No changes`：

```bash
terraform -chdir=lifecycle plan \
  -detailed-exitcode \
  -var="run_id=${VPC_TEST_RUN_ID}" \
  -var="phase=create"
```

## 原地更新与幂等验证

更新阶段会在同一个 VPC 上添加或修改名称、描述、DNS、Tags、辅助 CIDR 和 User CIDR：

```bash
terraform -chdir=lifecycle apply \
  -var="run_id=${VPC_TEST_RUN_ID}" \
  -var="phase=update"
```

更新后再次执行 Plan，预期为 `No changes`：

```bash
terraform -chdir=lifecycle plan \
  -detailed-exitcode \
  -var="run_id=${VPC_TEST_RUN_ID}" \
  -var="phase=update"
```

一旦 `phase=update` 已成功 Apply，不要再切回 `phase=create`。切回会尝试清空集合字段，并触发已知的 Provider `null`/空集合问题。后续 Plan 和 Destroy 都必须继续使用 `phase=update`。

记录 VPC ID：

```bash
export VPC_TEST_ID="$(terraform -chdir=lifecycle output -raw vpc_id)"
```

## Existing VPC 模式

Existing VPC 必须使用独立 State：

```bash
terraform -chdir=existing-vpc init
terraform -chdir=existing-vpc apply \
  -var="existing_vpc_id=${VPC_TEST_ID}"

terraform -chdir=existing-vpc plan \
  -detailed-exitcode \
  -var="existing_vpc_id=${VPC_TEST_ID}"

terraform -chdir=existing-vpc destroy \
  -var="existing_vpc_id=${VPC_TEST_ID}"
```

Existing VPC Destroy 应显示 `0 destroyed`。随后回到 `lifecycle/` 再次执行 `phase=update` 的 Plan，结果仍应为 `No changes`。

## 最终清理

销毁创建模式持有的 VPC：

```bash
terraform -chdir=lifecycle destroy \
  -var="run_id=${VPC_TEST_RUN_ID}" \
  -var="phase=update"
```

销毁后检查 State：

```bash
terraform -chdir=lifecycle state list
```

预期没有任何资源输出。测试失败时也必须使用与最后一次成功 Apply 相同的 `phase` 和 `run_id` 执行 Destroy。

测试结束后清除当前 Shell 中的凭证环境变量：

```bash
unset VOLCENGINE_ACCESS_KEY VOLCENGINE_SECRET_KEY VOLCENGINE_REGION
```

## IPv4 Gateway 专项说明

`ipv4-gateway/ipv4_gateway_api.go` 使用 `github.com/volcengine/volcengine-go-sdk` 的 VPC Client 进行签名和请求，依赖版本由同目录的 `go.mod` 固定。该工具是 Provider 能力分析用的可选 Spike，不属于 Module 的常规验证路径。完整生命周期顺序为：

1. `CreateIpv4Gateway` 创建未关联 Gateway。
2. Terraform 创建 VPC，并传入 Gateway ID；实测此步不会自动建立关联。
3. `AttachIpv4Gateway` 关联 VPC。
4. 在 VPC系统路由表中创建 `0.0.0.0/0 -> Ipv4GW` 路由。
5. `EnableIpv4Gateway` 启用 Gateway。
6. Terraform 第二次 Plan，预期为 `No changes`。
7. 按“停用、删除路由、解除关联、销毁 VPC、删除 Gateway”的逆序清理。

SDK工具不读取或保存配置文件中的明文凭证，只使用 `load-current-profile.sh` 导出的环境变量。不要对已有生产 Gateway执行该测试。

## 已知发布阻断项

Provider `0.0.60` 会将清空后的集合回读为 `null`，导致空集合配置产生永久 Plan 差异。因此当前 Module 拒绝空的 `dns_servers`、`secondary_cidr_blocks`、`user_cidr_blocks` 和 `tags`。本测试目录不会把该限制误报为通过；完整结论见 [`../docs/real-cloud-validation.md`](../docs/real-cloud-validation.md)。
