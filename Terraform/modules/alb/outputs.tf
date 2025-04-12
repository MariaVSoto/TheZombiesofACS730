output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.web_alb.arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.web_alb.zone_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = var.alb_security_group_id
}

output "target_group_arn" {
  description = "ARN of the web servers target group"
  value       = aws_lb_target_group.web.arn
}

output "static_target_group_arn" {
  description = "ARN of the static instances target group"
  value       = aws_lb_target_group.static.arn
} 