output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "cidr_block" {
  value = module.network.cidr_block
}

output "private_subnet_ids" {
  value = module.network.PrivateSubnet
}

output "public_subnet_ids" {
  value = module.network.PublicSubnet
}
