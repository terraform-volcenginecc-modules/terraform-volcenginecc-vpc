variable "region" {
  description = "Volcengine region in which to create the VPC."
  type        = string
  default     = "cn-beijing"
}

variable "name" {
  description = "Name of the example VPC."
  type        = string
  default     = "volcenginecc-vpc-complete"
}

variable "cidr_block" {
  description = "Primary IPv4 CIDR of the example VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "dns_servers" {
  description = "Optional DNS server IP addresses. Null uses the service defaults."
  type        = set(string)
  default     = null
}

variable "project_name" {
  description = "Optional project name. Null uses the service default project."
  type        = string
  default     = null
}
