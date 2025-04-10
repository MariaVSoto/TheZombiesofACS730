output "vpc_id" {
  value = aws_vpc.VPC.id
}

output "cidr_block" {
  value = aws_vpc.VPC.cidr_block
}

output "PublicSubnet" {
  value = aws_subnet.public[*].id
}

output "PrivateSubnet" {
  value = aws_subnet.private[*].id
}