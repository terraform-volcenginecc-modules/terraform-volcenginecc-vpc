provider "volcenginecc" {
  region = var.region
}

module "vpc" {
  source  = "volcengine/vpc/volcenginecc"
  version = "~> 1.0"

  create_vpc      = false
  existing_vpc_id = var.existing_vpc_id
}
