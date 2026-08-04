locals {
  resource_tags = var.tags == null ? null : [
    for key in sort(keys(var.tags)) : {
      key   = key
      value = var.tags[key]
    }
  ]
}

resource "volcenginecc_vpc_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  vpc_name              = var.name
  cidr_block            = var.cidr_block
  description           = var.description
  dns_servers           = var.dns_servers
  secondary_cidr_blocks = var.secondary_cidr_blocks
  user_cidr_blocks      = var.user_cidr_blocks
  enable_ipv_6          = var.enable_ipv6
  project_name          = var.project_name
  tags                  = local.resource_tags

  lifecycle {
    precondition {
      condition     = var.existing_vpc_id == null
      error_message = "existing_vpc_id must be null when create_vpc is true."
    }

    precondition {
      condition     = try(var.name != null && trimspace(var.name) != "", false)
      error_message = "name is required when create_vpc is true."
    }

    precondition {
      condition     = var.cidr_block != null
      error_message = "cidr_block is required when create_vpc is true."
    }

    precondition {
      condition = var.secondary_cidr_blocks == null || try(alltrue([
        for secondary_cidr in var.secondary_cidr_blocks :
        (
          tonumber(split(".", cidrhost(var.cidr_block, 0))[0]) == 10 &&
          tonumber(split(".", cidrhost(secondary_cidr, 0))[0]) == 10
          ) || (
          tonumber(split(".", cidrhost(var.cidr_block, 0))[0]) == 172 &&
          tonumber(split(".", cidrhost(var.cidr_block, 0))[1]) >= 16 &&
          tonumber(split(".", cidrhost(var.cidr_block, 0))[1]) <= 31 &&
          tonumber(split(".", cidrhost(secondary_cidr, 0))[0]) == 172 &&
          tonumber(split(".", cidrhost(secondary_cidr, 0))[1]) >= 16 &&
          tonumber(split(".", cidrhost(secondary_cidr, 0))[1]) <= 31
          ) || (
          tonumber(split(".", cidrhost(var.cidr_block, 0))[0]) == 192 &&
          tonumber(split(".", cidrhost(var.cidr_block, 0))[1]) == 168 &&
          tonumber(split(".", cidrhost(secondary_cidr, 0))[0]) == 192 &&
          tonumber(split(".", cidrhost(secondary_cidr, 0))[1]) == 168
        )
      ]), false)
      error_message = "secondary_cidr_blocks must belong to the same private address range as cidr_block (10/8, 172.16/12, or 192.168/16)."
    }
  }
}

data "volcenginecc_vpc_vpc" "existing" {
  count = var.create_vpc ? 0 : 1

  id = var.existing_vpc_id

  lifecycle {
    precondition {
      condition     = try(var.existing_vpc_id != null && trimspace(var.existing_vpc_id) != "", false)
      error_message = "existing_vpc_id is required when create_vpc is false."
    }

    precondition {
      condition = alltrue([
        var.name == null,
        var.cidr_block == null,
        var.description == null,
        var.dns_servers == null,
        var.secondary_cidr_blocks == null,
        var.user_cidr_blocks == null,
        var.enable_ipv6 == null,
        var.project_name == null,
        var.tags == null,
      ])
      error_message = "Creation inputs must remain null when create_vpc is false; existing VPC attributes are read from the provider."
    }
  }
}

locals {
  vpc_id = var.create_vpc ? volcenginecc_vpc_vpc.this[0].vpc_id : data.volcenginecc_vpc_vpc.existing[0].vpc_id

  vpc_name = var.create_vpc ? volcenginecc_vpc_vpc.this[0].vpc_name : data.volcenginecc_vpc_vpc.existing[0].vpc_name

  cidr_block = var.create_vpc ? volcenginecc_vpc_vpc.this[0].cidr_block : data.volcenginecc_vpc_vpc.existing[0].cidr_block

  secondary_cidr_blocks = var.create_vpc ? volcenginecc_vpc_vpc.this[0].secondary_cidr_blocks : data.volcenginecc_vpc_vpc.existing[0].secondary_cidr_blocks

  user_cidr_blocks = var.create_vpc ? volcenginecc_vpc_vpc.this[0].user_cidr_blocks : data.volcenginecc_vpc_vpc.existing[0].user_cidr_blocks

  ipv6_cidr_block = var.create_vpc ? volcenginecc_vpc_vpc.this[0].ipv_6_cidr_block : data.volcenginecc_vpc_vpc.existing[0].ipv_6_cidr_block

  enable_ipv6 = try(local.ipv6_cidr_block != null && local.ipv6_cidr_block != "", false)

  project_name = var.create_vpc ? volcenginecc_vpc_vpc.this[0].project_name : data.volcenginecc_vpc_vpc.existing[0].project_name

  support_ipv4_gateway = var.create_vpc ? volcenginecc_vpc_vpc.this[0].support_ipv_4_gateway : data.volcenginecc_vpc_vpc.existing[0].support_ipv_4_gateway

  ipv4_gateway_id = var.create_vpc ? volcenginecc_vpc_vpc.this[0].ipv_4_gateway_id : data.volcenginecc_vpc_vpc.existing[0].ipv_4_gateway_id

  provider_tags = var.create_vpc ? volcenginecc_vpc_vpc.this[0].tags : data.volcenginecc_vpc_vpc.existing[0].tags

  normalized_tags = local.provider_tags == null ? tomap({}) : tomap({
    for tag in local.provider_tags : tag.key => coalesce(tag.value, "")
  })

  route_table_ids = var.create_vpc ? volcenginecc_vpc_vpc.this[0].route_table_ids : data.volcenginecc_vpc_vpc.existing[0].route_table_ids

  is_default = var.create_vpc ? volcenginecc_vpc_vpc.this[0].is_default : data.volcenginecc_vpc_vpc.existing[0].is_default

  status = var.create_vpc ? volcenginecc_vpc_vpc.this[0].status : data.volcenginecc_vpc_vpc.existing[0].status
}
