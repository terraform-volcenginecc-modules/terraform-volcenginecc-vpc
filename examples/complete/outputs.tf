output "vpc_id" {
  description = "ID of the example VPC."
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "Name of the example VPC."
  value       = module.vpc.vpc_name
}

output "cidr_block" {
  description = "Primary IPv4 CIDR of the example VPC."
  value       = module.vpc.cidr_block
}

output "secondary_cidr_blocks" {
  description = "Secondary IPv4 CIDRs of the example VPC."
  value       = module.vpc.secondary_cidr_blocks
}

output "user_cidr_blocks" {
  description = "User IPv4 CIDRs of the example VPC."
  value       = module.vpc.user_cidr_blocks
}

output "project_name" {
  description = "Project of the example VPC."
  value       = module.vpc.project_name
}

output "tags" {
  description = "Tags of the example VPC."
  value       = module.vpc.tags
}

output "route_table_ids" {
  description = "Read-only route table associations reported by the Provider."
  value       = module.vpc.route_table_ids
}

output "status" {
  description = "Provider-reported VPC status."
  value       = module.vpc.status
}
