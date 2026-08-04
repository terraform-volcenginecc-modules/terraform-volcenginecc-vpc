output "vpc_id" {
  description = "ID of the existing VPC."
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "Name of the existing VPC."
  value       = module.vpc.vpc_name
}

output "cidr_block" {
  description = "Primary CIDR of the existing VPC."
  value       = module.vpc.cidr_block
}

output "secondary_cidr_blocks" {
  description = "Secondary CIDRs of the existing VPC."
  value       = module.vpc.secondary_cidr_blocks
}

output "user_cidr_blocks" {
  description = "User CIDRs of the existing VPC."
  value       = module.vpc.user_cidr_blocks
}

output "enable_ipv6" {
  description = "Whether IPv6 is enabled on the existing VPC."
  value       = module.vpc.enable_ipv6
}

output "ipv6_cidr_block" {
  description = "IPv6 CIDR of the existing VPC."
  value       = module.vpc.ipv6_cidr_block
}

output "support_ipv4_gateway" {
  description = "Whether IPv4 Gateway support is reported for the existing VPC."
  value       = module.vpc.support_ipv4_gateway
}

output "ipv4_gateway_id" {
  description = "IPv4 Gateway ID reported for the existing VPC."
  value       = module.vpc.ipv4_gateway_id
}

output "tags" {
  description = "Normalized tags of the existing VPC."
  value       = module.vpc.tags
}

output "status" {
  description = "Provider-reported VPC status."
  value       = module.vpc.status
}
