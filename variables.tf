variable "create_vpc" {
  description = "Whether to create and manage a new VPC. Do not toggle this value in place when migrating between created and existing VPC modes."
  type        = bool
  default     = true
  nullable    = false
}

variable "existing_vpc_id" {
  description = "ID of an existing VPC to read when create_vpc is false."
  type        = string
  default     = null

  validation {
    condition     = var.existing_vpc_id == null || trimspace(var.existing_vpc_id) != ""
    error_message = "existing_vpc_id must be null or a non-empty VPC ID."
  }
}

variable "name" {
  description = "Name of the VPC to create. Required when create_vpc is true."
  type        = string
  default     = null

  validation {
    condition     = var.name == null || (length(trimspace(var.name)) >= 1 && length(var.name) <= 128)
    error_message = "name must be null or contain between 1 and 128 characters."
  }

  validation {
    condition     = var.name == null || can(regex("^[\\p{L}\\p{N}][\\p{L}\\p{N}._-]*$", var.name))
    error_message = "name must start with a letter or number and may contain only letters, numbers, periods, underscores, and hyphens."
  }
}

variable "cidr_block" {
  description = "Primary IPv4 CIDR block of the VPC. Required when create_vpc is true. Changing it replaces the VPC."
  type        = string
  default     = null

  validation {
    condition     = var.cidr_block == null || can(cidrnetmask(var.cidr_block))
    error_message = "cidr_block must be a valid IPv4 CIDR."
  }

  validation {
    condition = var.cidr_block == null || try(
      cidrhost(var.cidr_block, 0) == split("/", var.cidr_block)[0] &&
      tonumber(split("/", var.cidr_block)[1]) <= 24 &&
      (
        (
          tonumber(split(".", cidrhost(var.cidr_block, 0))[0]) == 10 &&
          tonumber(split("/", var.cidr_block)[1]) >= 8
        ) ||
        (
          tonumber(split(".", cidrhost(var.cidr_block, 0))[0]) == 172 &&
          tonumber(split(".", cidrhost(var.cidr_block, 0))[1]) >= 16 &&
          tonumber(split(".", cidrhost(var.cidr_block, 0))[1]) <= 31 &&
          tonumber(split("/", var.cidr_block)[1]) >= 12
        ) ||
        (
          tonumber(split(".", cidrhost(var.cidr_block, 0))[0]) == 192 &&
          tonumber(split(".", cidrhost(var.cidr_block, 0))[1]) == 168 &&
          tonumber(split("/", var.cidr_block)[1]) >= 16
        )
      ),
      false
    )
    error_message = "cidr_block must be a canonical private network in 10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16 with a prefix no longer than /24."
  }
}

variable "description" {
  description = "Description of the VPC."
  type        = string
  default     = null

  validation {
    condition     = var.description == null || length(var.description) <= 255
    error_message = "description must contain at most 255 characters."
  }

  validation {
    condition     = var.description == null || var.description == "" || can(regex("^[\\p{L}\\p{N}][\\p{L}\\p{N},._ =\\-，。]*$", var.description))
    error_message = "description must start with a letter or number and contain only supported punctuation; URL prefixes are not allowed."
  }
}

variable "dns_servers" {
  description = "Optional non-empty set of DNS server IP addresses for the VPC. The provider supports at most five."
  type        = set(string)
  default     = null

  validation {
    condition     = var.dns_servers == null || length(var.dns_servers) <= 5
    error_message = "dns_servers must contain at most five addresses."
  }

  validation {
    condition     = var.dns_servers == null || length(var.dns_servers) > 0
    error_message = "dns_servers must be null or contain at least one address; empty sets are not supported because Provider v0.0.60 reads them back as null."
  }

  validation {
    condition = var.dns_servers == null || alltrue([
      for address in var.dns_servers :
      can(cidrhost("${address}/32", 0)) || can(cidrhost("${address}/128", 0))
    ])
    error_message = "Every dns_servers entry must be a valid IPv4 or IPv6 address."
  }
}

variable "secondary_cidr_blocks" {
  description = "Optional set containing one secondary IPv4 CIDR in the same private address range as cidr_block."
  type        = set(string)
  default     = null

  validation {
    condition = var.secondary_cidr_blocks == null || alltrue([
      for cidr in var.secondary_cidr_blocks : can(cidrnetmask(cidr))
    ])
    error_message = "Every secondary_cidr_blocks entry must be a valid IPv4 CIDR."
  }


  validation {
    condition     = var.secondary_cidr_blocks == null || length(var.secondary_cidr_blocks) == 1
    error_message = "secondary_cidr_blocks must be null or contain exactly one CIDR; Volcengine supports at most one secondary IPv4 CIDR per VPC."
  }

  validation {
    condition = var.secondary_cidr_blocks == null || alltrue([
      for cidr in var.secondary_cidr_blocks : try(
        cidrhost(cidr, 0) == split("/", cidr)[0] &&
        tonumber(split("/", cidr)[1]) <= 28 &&
        (
          (
            tonumber(split(".", cidrhost(cidr, 0))[0]) == 10 &&
            tonumber(split("/", cidr)[1]) >= 8
          ) ||
          (
            tonumber(split(".", cidrhost(cidr, 0))[0]) == 172 &&
            tonumber(split(".", cidrhost(cidr, 0))[1]) >= 16 &&
            tonumber(split(".", cidrhost(cidr, 0))[1]) <= 31 &&
            tonumber(split("/", cidr)[1]) >= 12
          ) ||
          (
            tonumber(split(".", cidrhost(cidr, 0))[0]) == 192 &&
            tonumber(split(".", cidrhost(cidr, 0))[1]) == 168 &&
            tonumber(split("/", cidr)[1]) >= 16
          )
        ),
        false
      )
    ])
    error_message = "secondary_cidr_blocks must contain a canonical private IPv4 network in 10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16 with a prefix no longer than /28."
  }
}

variable "user_cidr_blocks" {
  description = "Optional non-empty set of user IPv4 CIDR blocks to associate with the VPC."
  type        = set(string)
  default     = null

  validation {
    condition = var.user_cidr_blocks == null || alltrue([
      for cidr in var.user_cidr_blocks : can(cidrnetmask(cidr))
    ])
    error_message = "Every user_cidr_blocks entry must be a valid IPv4 CIDR."
  }


  validation {
    condition     = var.user_cidr_blocks == null || length(var.user_cidr_blocks) > 0
    error_message = "user_cidr_blocks must be null or non-empty; empty sets are not supported because Provider v0.0.60 reads them back as null."
  }
}

variable "enable_ipv6" {
  description = "Whether to enable an automatically allocated IPv6 CIDR block when creating the VPC. Do not toggle this write-only Provider field in place; updates require an extra refresh-only apply before Outputs become stable."
  type        = bool
  default     = null
}

variable "project_name" {
  description = "Project to which the VPC belongs. When omitted, the service default is used. Changing it replaces the VPC."
  type        = string
  default     = null

  validation {
    condition     = var.project_name == null || trimspace(var.project_name) != ""
    error_message = "project_name must be null or a non-empty project name."
  }
}

variable "tags" {
  description = "Optional non-empty map of tags to assign to the VPC."
  type        = map(string)
  default     = null

  validation {
    condition = var.tags == null || alltrue([
      for key in keys(var.tags) : trimspace(key) != ""
    ])
    error_message = "Tag keys must not be empty."
  }


  validation {
    condition     = var.tags == null || length(var.tags) > 0
    error_message = "tags must be null or non-empty; empty maps are not supported because Provider v0.0.60 reads them back as null."
  }
}
