provider "volcenginecc" {
  region = var.region
}

module "vpc" {
  source  = "volcengine/vpc/volcenginecc"
  version = "~> 1.0"

  name        = var.name
  cidr_block  = var.cidr_block
  enable_ipv6 = true

  tags = {
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}
