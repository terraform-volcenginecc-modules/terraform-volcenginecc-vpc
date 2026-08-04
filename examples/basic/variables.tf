variable "region" {
  description = "Volcengine region in which to create the VPC."
  type        = string
  default     = "cn-beijing"
}

variable "name" {
  description = "Name of the example VPC."
  type        = string
  default     = "volcenginecc-vpc-basic"
}

variable "cidr_block" {
  description = "Primary IPv4 CIDR of the example VPC."
  type        = string
  default     = "10.10.0.0/16"
}
