variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "team_name" {
  description = "Name of the team managing the resources"
  type        = string
}

variable "region" {
  description = "AWS region for deploying resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of AWS availability zones"
  type        = list(string)
}

# Tags
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "admin_ip_cidr" {
  description = "CIDR block for admin access"
  type        = string
  validation {
    condition     = can(cidrhost(var.admin_ip_cidr, 0))
    error_message = "The admin IP CIDR must be a valid CIDR block format. Please provide a valid CIDR notation (e.g., 10.0.0.0/24)."
  }
}