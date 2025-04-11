output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.VPC.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "bastion_sg_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion_sg.id
}

output "private_sg_id" {
  description = "ID of the private subnet security group"
  value       = aws_security_group.private_sg.id
} 