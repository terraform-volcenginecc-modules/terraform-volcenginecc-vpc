provider "volcenginecc" {
  region = var.region
}

module "vpc" {
  source = "../.."

  create_vpc      = false
  existing_vpc_id = var.existing_vpc_id
}
