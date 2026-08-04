provider "volcenginecc" {
  region = var.region
}

locals {
  is_update = var.phase == "update"
}

module "vpc" {
  source = "../.."

  name       = local.is_update ? "vpcmod-${var.run_id}-updated" : "vpcmod-${var.run_id}-created"
  cidr_block = "10.233.0.0/16"

  description = local.is_update ? "Real cloud lifecycle update validation" : null

  dns_servers = local.is_update ? [
    "100.96.0.2",
  ] : null

  secondary_cidr_blocks = local.is_update ? [
    "10.234.0.0/16",
  ] : null

  user_cidr_blocks = local.is_update ? [
    "100.64.0.0/10",
  ] : null

  tags = local.is_update ? {
    Environment = "acceptance"
    ManagedBy   = "Terraform"
    Phase       = "update"
    } : {
    Environment = "acceptance"
    ManagedBy   = "Terraform"
    Phase       = "create"
  }
}
