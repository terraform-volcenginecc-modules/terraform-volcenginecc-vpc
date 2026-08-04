variable "region" {
  description = "Volcengine region in which to create the dual-stack VPC."
  type        = string
  default     = "cn-beijing"
}

variable "name" {
  description = "Name of the dual-stack example VPC."
  type        = string
  default     = "volcenginecc-vpc-ipv6-dualstack"
}

variable "cidr_block" {
  description = "Primary IPv4 CIDR of the dual-stack VPC."
  type        = string
  default     = "10.40.0.0/16"
}
