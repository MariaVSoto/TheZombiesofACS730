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

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.web_role.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.web_role.arn
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.web_instance_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.web_instance_profile.arn
}

output "web_sg_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web_sg.id
}

output "bastion_instance_id" {
  description = "ID of the Bastion host instance"
  value       = aws_instance.bastion.id
}

output "webserver4_instance_id" {
  description = "ID of Webserver 4 instance"
  value       = aws_instance.webserver4.id
}

output "vm5_instance_id" {
  description = "ID of VM5 instance"
  value       = aws_instance.vm5.id
}

output "vm6_instance_id" {
  description = "ID of VM6 instance"
  value       = aws_instance.vm6.id
} 