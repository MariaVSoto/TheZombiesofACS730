variable "environment" {
  description = "Environment name (prod)"
  type        = string
  default     = "PROD"
}

variable "team_name" {
  description = "Name of the team"
  type        = string
  default     = "zombies"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.1.5.0/24", "10.1.6.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}
