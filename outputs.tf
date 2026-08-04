output "vpc_id" {
  description = "ID of the created or existing VPC."
  value       = local.vpc_id
}

output "vpc_name" {
  description = "Name of the created or existing VPC."
  value       = local.vpc_name
}

output "cidr_block" {
  description = "Primary IPv4 CIDR block of the VPC."
  value       = local.cidr_block
}

output "secondary_cidr_blocks" {
  description = "Secondary IPv4 CIDR blocks associated with the VPC."
  value       = local.secondary_cidr_blocks
}

output "user_cidr_blocks" {
  description = "User IPv4 CIDR blocks associated with the VPC."
  value       = local.user_cidr_blocks
}

output "enable_ipv6" {
  description = "Whether the Provider reports a non-empty IPv6 CIDR for the VPC."
  value       = local.enable_ipv6
}

output "ipv6_cidr_block" {
  description = "IPv6 CIDR allocated to the VPC, or an empty value when IPv6 is disabled."
  value       = local.ipv6_cidr_block
}

output "project_name" {
  description = "Project to which the VPC belongs."
  value       = local.project_name
}

output "support_ipv4_gateway" {
  description = "Whether IPv4 Gateway support is enabled."
  value       = local.support_ipv4_gateway
}

output "ipv4_gateway_id" {
  description = "ID of the IPv4 Gateway bound to the VPC, or null when none is bound."
  value       = local.ipv4_gateway_id
}

output "tags" {
  description = "Tags associated with the VPC, normalized as a map."
  value       = local.normalized_tags
}

output "route_table_ids" {
  description = "Read-only route table associations reported by the provider. This output does not imply ownership."
  value       = local.route_table_ids
}

output "is_default" {
  description = "Whether the VPC is the account's default VPC."
  value       = local.is_default
}

output "status" {
  description = "Current VPC status reported by the provider."
  value       = local.status
}
