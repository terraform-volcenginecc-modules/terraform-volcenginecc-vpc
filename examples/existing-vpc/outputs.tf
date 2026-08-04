output "vpc_id" {
  description = "ID of the existing VPC."
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "Name of the existing VPC."
  value       = module.vpc.vpc_name
}

output "cidr_block" {
  description = "Primary IPv4 CIDR of the existing VPC."
  value       = module.vpc.cidr_block
}

output "is_default" {
  description = "Whether the existing VPC is the default VPC."
  value       = module.vpc.is_default
}
