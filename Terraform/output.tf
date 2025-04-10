output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc-Prod.vpc_id
}

output "cidr_block" {
  value = module.vpc-Prod.cidr_block
}

output "private_subnet_ids" {
  value = module.vpc-Prod.PrivateSubnet
}
