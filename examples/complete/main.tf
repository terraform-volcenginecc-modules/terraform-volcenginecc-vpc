provider "volcenginecc" {
  region = var.region
}

module "vpc" {
  source  = "volcengine/vpc/volcenginecc"
  version = "~> 1.0"

  name        = var.name
  cidr_block  = var.cidr_block
  description = "Complete example for terraform-volcenginecc-vpc"
  enable_ipv6 = true

  dns_servers = var.dns_servers

  secondary_cidr_blocks = [
    "10.21.0.0/16",
  ]

  user_cidr_blocks = [
    "192.168.0.0/16",
  ]

  project_name = var.project_name

  tags = {
    Environment = "example"
    ManagedBy   = "Terraform"
    Module      = "terraform-volcenginecc-vpc"
  }
}
