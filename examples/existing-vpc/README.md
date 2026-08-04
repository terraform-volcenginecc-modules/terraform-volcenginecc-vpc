# Existing VPC

Reads a VPC by explicit ID without creating it or taking ownership of its lifecycle.

```shell
terraform apply -var='existing_vpc_id=vpc-xxxxxxxx'
terraform destroy -var='existing_vpc_id=vpc-xxxxxxxx'
```

Destroy removes only the Module data from Terraform state; it must not delete the existing VPC.
