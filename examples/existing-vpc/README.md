# EXISTING VPC VPC Example

## Overview

Runnable existing-vpc configuration for the VPC module. It configures the provider from input variables and calls the published Registry module.

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
| `existing_vpc_id` | Module-defined existing_vpc_id. |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | Module-defined vpc_id. |
| `vpc_name` | Module-defined vpc_name. |
| `cidr_block` | Module-defined cidr_block. |
| `is_default` | Module-defined is_default. |

## Examples

This directory is the existing-vpc example.

## Notes

- Supply credentials through supported provider configuration, never in source files.
- The final plan after apply must report no changes before the configuration is accepted.
