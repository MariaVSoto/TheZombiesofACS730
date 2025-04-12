output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.VPC.id
}

output "cidr_block" {
  description = "CIDR block of the created VPC"
  value       = aws_vpc.VPC.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = { for i, subnet in aws_subnet.public : "public-${i + 1}" => subnet.id }
}

output "private_subnet_ids" {
  description = "IDs of the created private subnets"
  value       = { for i, subnet in aws_subnet.private : "private-${i + 1}" => subnet.id }
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web_sg.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion_sg.id
}

output "private_security_group_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private_sg.id
} 