output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the created VPC"
  value       = module.network.cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the created private subnets"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = module.network.public_subnet_ids
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.network.web_security_group_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.network.alb_security_group_id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = module.network.bastion_security_group_id
}

output "private_security_group_id" {
  description = "ID of the private security group"
  value       = module.network.private_security_group_id
}
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_group_arn" {
  value = module.alb.target_group_arn
} 