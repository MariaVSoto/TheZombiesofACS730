output "webserver4_public_ip" {
  description = "Public IP of webserver4"
  value       = module.webserver.webserver4_public_ip
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.webserver.bastion_public_ip
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.network.vpc_id
} 