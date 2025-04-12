output "web_security_group_id" {
  description = "ID of the web servers security group"
  value       = aws_security_group.web_sg.id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}

output "webserver2_id" {
  description = "Instance ID of Webserver 2 (Bastion)"
  value       = aws_instance.webserver2.id
}

output "webserver4_id" {
  description = "Instance ID of Webserver 4"
  value       = aws_instance.webserver4.id
}

output "webserver5_id" {
  description = "Instance ID of Webserver 5"
  value       = aws_instance.webserver5.id
}

output "vm6_id" {
  description = "Instance ID of VM 6"
  value       = aws_instance.vm6.id
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.web_instance_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.web_instance_profile.arn
} 