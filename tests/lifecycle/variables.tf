variable "region" {
  description = "Volcengine region used by the real-cloud test."
  type        = string
  default     = "cn-beijing"
}

variable "run_id" {
  description = "Unique suffix used in test resource names."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]{0,39}$", var.run_id))
    error_message = "run_id must start with a letter or number and contain at most 40 letters, numbers, or hyphens."
  }
}

variable "phase" {
  description = "Lifecycle phase: create establishes the baseline; update modifies mutable fields and adds optional CIDRs."
  type        = string
  default     = "create"

  validation {
    condition     = contains(["create", "update"], var.phase)
    error_message = "phase must be create or update."
  }
}
