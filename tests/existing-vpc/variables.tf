variable "region" {
  description = "Volcengine region containing the existing VPC."
  type        = string
  default     = "cn-beijing"
}

variable "existing_vpc_id" {
  description = "ID of the VPC created by the lifecycle fixture."
  type        = string

  validation {
    condition     = trimspace(var.existing_vpc_id) != ""
    error_message = "existing_vpc_id must not be empty."
  }
}
