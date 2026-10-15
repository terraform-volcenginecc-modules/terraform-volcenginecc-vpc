# SECONDARY CIDR BLOCKS VPC Example

## Overview

Runnable secondary-cidr-blocks configuration for the VPC module. It configures the provider from input variables and calls the published Registry module.

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

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | Module-defined vpc_id. |
| `secondary_cidr_blocks` | Module-defined secondary_cidr_blocks. |

## Examples

This directory is the secondary-cidr-blocks example.

## Notes

- Supply credentials through supported provider configuration, never in source files.
- The final plan after apply must report no changes before the configuration is accepted.
