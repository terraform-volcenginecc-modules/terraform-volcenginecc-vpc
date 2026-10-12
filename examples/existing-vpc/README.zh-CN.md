# 既有 VPC

通过显式指定的 ID 读取一个已存在的 VPC，既不创建它，也不接管其生命周期。

```shell
terraform apply -var='existing_vpc_id=vpc-xxxxxxxx'
terraform destroy -var='existing_vpc_id=vpc-xxxxxxxx'
```

destroy 只会从 Terraform 状态中移除本模块的数据；它绝不应删除该既有 VPC。
