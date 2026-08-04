variable "region" {
  description = "Volcengine region used by the IPv4 Gateway Provider spike."
  type        = string
  default     = "cn-beijing"
}

variable "run_id" {
  description = "Unique suffix used in the spike VPC name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]{0,39}$", var.run_id))
    error_message = "run_id must start with a letter or number and contain at most 40 letters, numbers, or hyphens."
  }
}

variable "ipv4_gateway_id" {
  description = "ID of the IPv4 Gateway created through the native VPC API for this spike."
  type        = string

  validation {
    condition     = can(regex("^ipv4gw-[A-Za-z0-9]+$", var.ipv4_gateway_id))
    error_message = "ipv4_gateway_id must be a non-empty IPv4 Gateway ID beginning with ipv4gw-."
  }
}
