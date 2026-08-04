output "vpc_id" {
  description = "ID of the example VPC."
  value       = module.vpc.vpc_id
}

output "secondary_cidr_blocks" {
  description = "Secondary IPv4 CIDRs associated with the example VPC."
  value       = module.vpc.secondary_cidr_blocks
}
