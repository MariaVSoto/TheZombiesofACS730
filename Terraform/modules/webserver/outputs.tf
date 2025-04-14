output "web_security_group_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web_sg.id
}

output "private_security_group_id" {
  description = "ID of the private instance security group"
  value       = aws_security_group.private_sg.id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}

output "launch_template_name" {
  description = "Name of the Launch Template for ASG instances"
  value       = aws_launch_template.asg_lt.name
}

output "bastion_launch_template_name" {
  description = "Name of the Launch Template for Bastion host"
  value       = aws_launch_template.bastion_lt.name
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "webserver4_public_ip" {
  description = "Public IP of webserver4"
  value       = aws_instance.webserver4.public_ip
}

output "vm5_private_ip" {
  description = "Private IP of VM5"
  value       = aws_instance.vm5.private_ip
}

output "vm6_private_ip" {
  description = "Private IP of VM6"
  value       = aws_instance.vm6.private_ip
} 