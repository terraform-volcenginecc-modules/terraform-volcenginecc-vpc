variable "region" {
  description = "Volcengine region containing the existing VPC."
  type        = string
  default     = "cn-beijing"
}

variable "existing_vpc_id" {
  description = "ID of the existing VPC to read."
  type        = string
}
