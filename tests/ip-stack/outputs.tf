output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cidr_block" {
  value = module.vpc.cidr_block
}

output "enable_ipv6" {
  value = module.vpc.enable_ipv6
}

output "ipv6_cidr_block" {
  value = module.vpc.ipv6_cidr_block
}

output "support_ipv4_gateway" {
  value = module.vpc.support_ipv4_gateway
}

output "ipv4_gateway_id" {
  value = module.vpc.ipv4_gateway_id
}

output "status" {
  value = module.vpc.status
}
