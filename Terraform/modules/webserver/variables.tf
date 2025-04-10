variable "team_name" {
  description = "Name of the team for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "web_server_count" {
  description = "Number of web servers to create in public subnets"
  type        = number
  default     = 2
}

variable "bastion_server_count" {
  description = "Number of bastion hosts to create"
  type        = number
  default     = 1
}

variable "private_server_count" {
  description = "Number of servers to create in private subnets"
  type        = number
  default     = 2
}

variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "web_security_group_id" {
  description = "Security group ID for web servers"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket containing web content"
  type        = string
}