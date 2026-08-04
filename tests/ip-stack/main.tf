provider "volcenginecc" {
  region = var.region
}

locals {
  enable_ipv6 = var.phase == "dualstack"
}

module "vpc" {
  source = "../.."

  name       = "vpcmod-ip-${var.run_id}"
  cidr_block = "10.235.0.0/16"

  enable_ipv6 = local.enable_ipv6

  tags = {
    ManagedBy = "Terraform"
    Scenario  = "ip-stack-validation"
  }
}
