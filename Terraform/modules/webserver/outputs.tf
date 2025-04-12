output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.asg.name
}

output "launch_configuration_name" {
  description = "Name of the Launch Configuration"
  value       = aws_launch_configuration.launch_config.name
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