# COMPLETE VPC Example

## Overview

Runnable complete configuration for the VPC module. It configures the provider from input variables and calls the published Registry module.

## Usage

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

## Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |

## Providers

| Name | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## Resources

| Name | Description |
|---|---|
| `terraform-volcenginecc-modules/vpc/volcenginecc` | Published VPC module. |

## Inputs

| Name | Description |
|---|---|
| `region` | Module-defined region. |
| `name` | Module-defined name. |
| `cidr_block` | Module-defined cidr_block. |
| `dns_servers` | Module-defined dns_servers. |
| `project_name` | Module-defined project_name. |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | Module-defined vpc_id. |
| `vpc_name` | Module-defined vpc_name. |
| `cidr_block` | Module-defined cidr_block. |
| `enable_ipv6` | Module-defined enable_ipv6. |
| `ipv6_cidr_block` | Module-defined ipv6_cidr_block. |
| `secondary_cidr_blocks` | Module-defined secondary_cidr_blocks. |
| `user_cidr_blocks` | Module-defined user_cidr_blocks. |
| `project_name` | Module-defined project_name. |
| `tags` | Module-defined tags. |
| `route_table_ids` | Module-defined route_table_ids. |
| `status` | Module-defined status. |

## Examples

This directory is the complete example.

## Notes

- Supply credentials through supported provider configuration, never in source files.
- The final plan after apply must report no changes before the configuration is accepted.
