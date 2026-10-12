# 基础 VPC

创建一个最小化的 IPv4 VPC，仅指定名称、CIDR 和标签。

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

在 apply 之后立即执行的 plan 必须报告无变更。请通过 Provider 支持的环境变量或配置文件（profile）配置凭证，不要将凭证写入这些文件。
