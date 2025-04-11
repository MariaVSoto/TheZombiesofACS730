# Environment Settings
environment = "prod"
team_name   = "zombies"
region      = "us-east-1"

# Network Settings
vpc_cidr = "10.1.0.0/16"

public_subnets = [
  "10.1.1.0/24",
  "10.1.2.0/24",
  "10.1.3.0/24",
  "10.1.4.0/24"
]

private_subnets = [
  "10.1.5.0/24",
  "10.1.6.0/24"
]

availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c",
  "us-east-1d"
]

# Security Settings
admin_ip_cidr = "0.0.0.0/0"  # Should be replaced with your actual IP

# EC2 Instance Settings
instance_type = "t2.small"
key_name      = "zombieacs730"
ami_id        = "ami-00a929b66ed6e0de6"  # Amazon Linux 2023 AMI for us-east-1

# s3 Settings
s3_bucket = "thezombiesofacs730"

# Auto Scaling Group Settings
asg_min_size         = 2
asg_max_size         = 4
asg_desired_capacity = 2

# Project Settings
project_name = "ACS730"

# Tag Settings
common_tags = {
  Team        = "zombies"
  Project     = "ACS730"
  Terraform   = "true"
}

additional_tags = {
  Owner       = "Zombies Team"
  Department  = "Cloud Computing"
} 