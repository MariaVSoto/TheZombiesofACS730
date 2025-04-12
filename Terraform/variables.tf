variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "team_name" {
  description = "Name of the team managing the resources"
  type        = string
}

variable "group_name" {
  description = "Name of the project group, used for resource naming"
  type        = string
  default     = "zombies"
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

variable "instance_type" {
  description = "EC2 instance type for the web servers"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key content for EC2 instances"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
  default     = 2
}

variable "ami_id" {
  description = "ID of the AMI to use for EC2 instances"
  type        = string
}

variable "s3_bucket" {
  description = "Name of the S3 bucket for web content and ALB logs"
  type        = string
}

variable "admin_ip_cidr" {
  description = "CIDR block for admin access to bastion host"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ACS730"
}

variable "cost_center" {
  description = "Cost center for resource billing"
  type        = string
  default     = "ACS730-Project"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Zombies Team"
}

variable "managed_by" {
  description = "Tool or team managing the resources"
  type        = string
  default     = "Terraform"
}

variable "additional_tags" {
  description = "Additional tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "terraform_state_bucket" {
  description = "Name of the S3 bucket for storing Terraform state"
  type        = string
  default     = "zombies-acs730"
}

variable "terraform_state_key" {
  description = "Object key for storing Terraform state file"
  type        = string
  default     = "terraform.tfstate"
}
