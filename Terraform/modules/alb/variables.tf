variable "environment" {
  description = "Environment name"
  type        = string
}

variable "team_name" {
  description = "Team name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "webserver1_id" {
  description = "Instance ID for Webserver 1"
  type        = string
}

variable "webserver2_id" {
  description = "Instance ID of Webserver 2"
  type        = string
}

variable "webserver3_id" {
  description = "Instance ID for Webserver 3"
  type        = string
}

variable "webserver4_id" {
  description = "Instance ID of Webserver 4"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
} 