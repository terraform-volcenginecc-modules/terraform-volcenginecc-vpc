# terraform-volcenginecc-vpc

Terraform module for creating a Volcengine VPC or reading an explicitly identified existing VPC with the `volcenginecc` provider.

## Overview

This module manages the VPC boundary only. It intentionally does not create subnets, route tables, security groups, NAT gateways, EIPs, Internet gateways, flow logs, or PrivateLink endpoints. Those resources should be composed through separate modules by using the `vpc_id` output.

The module supports two ownership modes:

- Create mode (`create_vpc = true`): creates and owns one `volcenginecc_vpc_vpc`.
- Existing mode (`create_vpc = false`): reads `existing_vpc_id` through a data source and does not own or destroy that VPC.

Do not toggle `create_vpc` in place. Changing from create mode to existing mode may destroy the managed VPC, while the reverse transition creates a new VPC. Use a new module address or a reviewed Terraform state/import migration instead.

## Usage

```hcl
module "vpc" {
  source  = "volcengine/vpc/volcenginecc"
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

Provider authentication and region configuration belong in the caller:

```hcl
provider "volcenginecc" {
  region = "cn-beijing"
}
```

Use environment variables, a profile, or another supported credential source. Do not put access keys in Module configuration.

## Existing VPC

```hcl
module "vpc" {
  source  = "volcengine/vpc/volcenginecc"
  version = "~> 1.0"

  create_vpc      = false
  existing_vpc_id = "vpc-xxxxxxxx"
}
```

Creation inputs must remain unset in existing mode. This prevents configuration from appearing accepted while being silently ignored.

## Examples

- [basic](examples/basic): creates a minimal IPv4 VPC.
- [complete](examples/complete): covers the stable VPC inputs.
- [secondary-cidr-blocks](examples/secondary-cidr-blocks): isolates secondary CIDR behavior.
- [existing-vpc](examples/existing-vpc): reads an explicitly identified VPC without taking ownership.
- [ipv6-dualstack](examples/ipv6-dualstack): creates an IPv4/IPv6 dual-stack VPC with an automatically allocated IPv6 CIDR.

## Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.0` |
| `volcengine/volcenginecc` | `>= 0.0.60` |

The supported create, update, no-change, existing-VPC, replacement-plan, and destroy scenarios were verified against a real `cn-beijing` account with Provider `0.0.60`. Collection clearing remains a Provider-blocked publication gate; see [real-cloud validation](docs/real-cloud-validation.md).

Reusable acceptance fixtures are retained in [tests](tests).

## Providers

| Name | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## Resources

| Mode | Type | Name |
|---|---|---|
| Create | Resource | `volcenginecc_vpc_vpc.this` |
| Existing | Data Source | `volcenginecc_vpc_vpc.existing` |

## Inputs

| Name | Type | Default | Required in create mode | Description |
|---|---|---:|---:|---|
| `create_vpc` | `bool` | `true` | No | Selects create or existing mode. Do not toggle in place. |
| `existing_vpc_id` | `string` | `null` | No | Required in existing mode. |
| `name` | `string` | `null` | Yes | VPC name. |
| `cidr_block` | `string` | `null` | Yes | Canonical private IPv4 CIDR. Changing it replaces the VPC. |
| `description` | `string` | `null` | No | VPC description. |
| `dns_servers` | `set(string)` | `null` | No | One to five DNS server IP addresses when set. |
| `secondary_cidr_blocks` | `set(string)` | `null` | No | Exactly one secondary IPv4 CIDR when set, in the same private address range as the primary CIDR. |
| `user_cidr_blocks` | `set(string)` | `null` | No | Non-empty user IPv4 CIDRs when set. |
| `enable_ipv6` | `bool` | `null` | No | Enables automatic IPv6 CIDR allocation at creation time. Do not toggle in place. |
| `project_name` | `string` | `null` | No | Project name. Changing it replaces the VPC. |
| `tags` | `map(string)` | `null` | No | Non-empty VPC tags when set. |

## Outputs

| Name | Type | Description |
|---|---|---|
| `vpc_id` | `string` | Created or existing VPC ID. |
| `vpc_name` | `string` | VPC name. |
| `cidr_block` | `string` | Primary IPv4 CIDR. |
| `secondary_cidr_blocks` | `set(string)` | Secondary IPv4 CIDRs. |
| `user_cidr_blocks` | `set(string)` | User IPv4 CIDRs. |
| `enable_ipv6` | `bool` | Whether a non-empty IPv6 CIDR is reported. |
| `ipv6_cidr_block` | `string` | Automatically allocated IPv6 CIDR, or an empty value when disabled. |
| `project_name` | `string` | Project name. |
| `support_ipv4_gateway` | `bool` | Read-only Provider report for IPv4 Gateway support. |
| `ipv4_gateway_id` | `string` | Read-only bound IPv4 Gateway ID, or an empty value. |
| `tags` | `map(string)` | Tags normalized from the Provider representation. |
| `route_table_ids` | `set(string)` | Read-only route table associations. This does not imply ownership. |
| `is_default` | `bool` | Whether the VPC is the default VPC. |
| `status` | `string` | Provider-reported VPC status. |

## Notes

- `cidr_block` and `project_name` are create-only Provider fields. Changing either replaces the VPC.
- The module does not automatically discover the default VPC because the current plural VPC data source cannot filter by `is_default`.
- `enable_ipv6 = true` was verified for creation, refresh, a second no-change Plan, Existing VPC reads, and destroy. The Provider field is write-only; toggling it in place succeeds but the immediately following Plan contains a refresh-only IPv6 CIDR Output change. Treat it as a creation-time setting.
- A custom IPv6 CIDR input is not exposed because add/change/remove could not be safely verified with an account-owned prefix.
- IPv4 Gateway is intentionally read-only in this module. Supplying `support_ipv_4_gateway` and an unattached `ipv_4_gateway_id` during VPC creation does not attach or enable the Gateway. A native API workflow must create the Gateway, attach it to the VPC, add an `Ipv4GW` default route, and enable it before the Provider reads back the configured values. The retained spike covers this dependency and reaches a no-change Plan after native setup.
- The module validates CIDR syntax, documented private ranges, the one-secondary-CIDR quota, and that primary and secondary CIDRs use the same private address range. Cloud-side overlap rules still apply.
- For `dns_servers`, `secondary_cidr_blocks`, `user_cidr_blocks`, and `tags`, use `null` to leave the setting unspecified and a non-empty collection to manage it. Empty collections are rejected because Provider v0.0.60 reads them back as `null`, which otherwise causes a permanent plan difference. Changing a managed non-empty collection to `null` stops declaring it; it does not clear the cloud-side value.
- `route_table_ids` is diagnostic read-only information. This module does not own those route tables.
- Apply must be followed by another `terraform plan`; a release is acceptable only when the second plan reports no changes.
