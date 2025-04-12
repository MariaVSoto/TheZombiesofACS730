# output "vpc_id" {
#   value = aws_vpc.VPC.id
# }

# output "cidr_block" {
#   value = aws_vpc.VPC.cidr_block
# }

# output "PublicSubnet" {
#   value = aws_subnet.public[*].id
# }

# output "PrivateSubnet" {
#   value = aws_subnet.private[*].id
# }

# output "web_security_group_id" {
#   description = "ID of the web server security group"
#   value       = aws_security_group.web_sg.id
# }

# output "bastion_security_group_id" {
#   description = "ID of the bastion host security group"
#   value       = aws_security_group.bastion_sg.id
# }

# output "private_security_group_id" {
#   description = "ID of the private subnet security group"
#   value       = aws_security_group.private_sg.id
# }