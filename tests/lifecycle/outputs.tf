output "vpc_id" {
  description = "ID of the VPC under lifecycle test."
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "Current VPC name."
  value       = module.vpc.vpc_name
}

output "cidr_block" {
  description = "Primary VPC CIDR."
  value       = module.vpc.cidr_block
}

output "secondary_cidr_blocks" {
  description = "Secondary CIDRs reported by the Provider."
  value       = module.vpc.secondary_cidr_blocks
}

output "user_cidr_blocks" {
  description = "User CIDRs reported by the Provider."
  value       = module.vpc.user_cidr_blocks
}

output "tags" {
  description = "Normalized VPC tags."
  value       = module.vpc.tags
}

output "status" {
  description = "Provider-reported VPC status."
  value       = module.vpc.status
}
