provider "volcenginecc" {
  region = var.region
}

resource "volcenginecc_vpc_vpc" "spike" {
  vpc_name              = "vpcmod-ipv4gw-${var.run_id}"
  cidr_block            = "10.236.0.0/16"
  support_ipv_4_gateway = true
  ipv_4_gateway_id      = var.ipv4_gateway_id

  tags = [{
    key   = "Scenario"
    value = "ipv4-gateway-provider-spike"
  }]
}

output "vpc_id" {
  value = volcenginecc_vpc_vpc.spike.vpc_id
}

output "support_ipv4_gateway" {
  value = volcenginecc_vpc_vpc.spike.support_ipv_4_gateway
}

output "ipv4_gateway_id" {
  value = volcenginecc_vpc_vpc.spike.ipv_4_gateway_id
}
