output "vpc_id" {
  description = "ID of the dual-stack VPC."
  value       = module.vpc.vpc_id
}

output "ipv4_cidr_block" {
  description = "Primary IPv4 CIDR of the VPC."
  value       = module.vpc.cidr_block
}

output "ipv6_cidr_block" {
  description = "Automatically allocated IPv6 CIDR of the VPC."
  value       = module.vpc.ipv6_cidr_block
}
