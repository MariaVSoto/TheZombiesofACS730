# Environment Settings
environment = "prod"
team_name   = "zombies"
group_name  = "zombies"
region      = "us-east-1"

# Network Settings
vpc_cidr = "10.1.0.0/16"

public_subnets = [
  "10.1.1.0/24", # Webserver 1 (ASG)
  "10.1.2.0/24", # Webserver 2 (Bastion)
  "10.1.3.0/24", # Webserver 3 (ASG)
  "10.1.4.0/24"  # Webserver 4
]

private_subnets = [
  "10.1.5.0/24", # Webserver 5
  "10.1.6.0/24"  # VM 6
]

availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c",
  "us-east-1d"
]

# Security Settings
admin_ip_cidr = "0.0.0.0/0" # TODO: Replace with specific IP range for security

# EC2 Instance Settings
instance_type = "t2.small"
key_name      = "zombieacs730"
ami_id        = "ami-00a929b66ed6e0de6" # Amazon Linux 2023 AMI for us-east-1

# SSH Key
ssh_public_key = "ssh-rsa AAAAB3NZaC1yc2EAAAADAQABAAABAQDAaN8XWeSStmO8WSZxvYuYY0BHn7IgYtpYvXtAvhcgiBuWOSi61LPjDBF5fJlTOtUhb+nXBDv/9BxygONSEvMXwHfDdZnQtuD6WMJPCNQFkTCvqd/B+IxNDwpzJ8HWPz7W1wK0N0A4UrhBKvVNP3O4lY2raOY3GeitjZDvDz3l3J9bJt7zXxfEGTKnF2xcXWwSy88KE3ojoXYYwVR4HjfOGmhIO9YKUcFOzqHr3Y9pDyatX7s1eLAyXo0fwrWYWN+kf0vdAGpsSzFjbTtLmgER2t0nwY8J4kkbDhrIoZALFxw0YyApXYQ/5EGcF0RgrDE5IUa9vK9BhbmhazPpIisp ec2-user@ip-172-31-6-3.ec2.internal"


# S3 Settings
s3_bucket          = "thezombiesofacs730"
access_logs_bucket = "thezombiesofacs730-logs" # Added for ALB access logs

# Auto Scaling Group Settings (for Webserver 1 and 3)
asg_min_size         = 2 # Minimum one instance each for Webserver 1 and 3
asg_max_size         = 4 # Maximum two instances each for Webserver 1 and 3
asg_desired_capacity = 2 # Desired one instance each for Webserver 1 and 3

# Static Instance Settings
bastion_subnet_index = 1 # Webserver 2 in public subnet 2
web4_subnet_index    = 3 # Webserver 4 in public subnet 4
web5_subnet_index    = 0 # Webserver 5 in private subnet 1
vm6_subnet_index     = 1 # VM 6 in private subnet 2

# Project Settings
project_name = "ACS730"
cost_center  = "ACS730-Project"
owner        = "Zombies Team"
managed_by   = "Terraform"

# Tag Settings
common_tags = {
  Team        = "zombies"
  Project     = "ACS730"
  Environment = "prod"
  Terraform   = "true"
  CostCenter  = "ACS730-Project"
  Owner       = "Zombies Team"
  ManagedBy   = "Terraform"
}

additional_tags = {
  Department = "Cloud Computing"
  Purpose    = "Education"
} 