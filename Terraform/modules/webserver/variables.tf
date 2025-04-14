variable "team_name" {
  type        = string
  description = "Name of the team for resource naming"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket name for storing artifacts"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instances"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instances"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where resources will be created"
}

variable "bastion_sg_id" {
  type        = string
  description = "Security group ID of the bastion host"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID of the Application Load Balancer"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair"
}

variable "public_key" {
  description = "SSH public key"
  type        = string
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired number of instances in the Auto Scaling Group"
  default     = 2
}

variable "asg_max_size" {
  type        = number
  description = "Maximum number of instances in the Auto Scaling Group"
  default     = 4
}

variable "asg_min_size" {
  type        = number
  description = "Minimum number of instances in the Auto Scaling Group"
  default     = 2
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB target group"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "bastion_subnet_index" {
  type        = number
  description = "Index of the public subnet for bastion host"
}

variable "web4_subnet_index" {
  type        = number
  description = "Index of the public subnet for webserver4"
}

variable "web5_subnet_index" {
  type        = number
  description = "Index of the private subnet for VM5"
}

variable "vm6_subnet_index" {
  type        = number
  description = "Index of the private subnet for VM6"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to be applied to all resources"
  default     = {}
}

variable "admin_ip_cidr" {
  description = "CIDR block for administrative access"
  type        = string
  default     = "0.0.0.0/0" # Consider restricting this to your IP
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
