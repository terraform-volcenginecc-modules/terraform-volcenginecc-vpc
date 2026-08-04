output "vpc_id" {
  description = "ID of the example VPC."
  value       = module.vpc.vpc_id
}

output "cidr_block" {
  description = "Primary IPv4 CIDR of the example VPC."
  value       = module.vpc.cidr_block
}
