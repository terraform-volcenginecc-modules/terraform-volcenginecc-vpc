variable "region" {
  description = "Volcengine region used by the IP stack test."
  type        = string
  default     = "cn-beijing"
}

variable "run_id" {
  description = "Unique suffix used in the test VPC name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]{0,39}$", var.run_id))
    error_message = "run_id must start with a letter or number and contain at most 40 letters, numbers, or hyphens."
  }
}

variable "phase" {
  description = "IP feature combination under test."
  type        = string
  default     = "dualstack"

  validation {
    condition     = contains(["ipv4-only", "dualstack"], var.phase)
    error_message = "phase must be ipv4-only or dualstack."
  }
}
