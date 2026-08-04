provider "volcenginecc" {
  region = var.region
}

module "vpc" {
  source  = "volcengine/vpc/volcenginecc"
  version = "~> 1.0"

  name       = "volcenginecc-vpc-secondary-cidrs"
  cidr_block = "10.30.0.0/16"

  secondary_cidr_blocks = [
    "10.31.0.0/16",
  ]

  tags = {
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}
