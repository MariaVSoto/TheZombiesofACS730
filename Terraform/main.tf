terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }
  required_version = ">= 0.14"
}

# Network Module
module "network" {
  source = "./modules/network"

  environment        = var.environment
  team_name         = var.team_name
  vpc_cidr          = var.vpc_cidr
  public_subnets    = var.public_subnets
  private_subnets   = var.private_subnets
  availability_zones = var.availability_zones
  region            = var.region
  
  # Add admin IP for bastion access
  admin_ip_cidr     = var.admin_ip_cidr
}

# Webserver Module
module "webserver" {
  source = "./modules/webserver"

  environment          = var.environment
  team_name           = var.team_name
  vpc_id              = module.network.vpc_id
  bastion_sg_id       = module.network.bastion_sg_id
  public_subnet_ids   = module.network.public_subnet_ids
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  key_name            = var.key_name
  s3_bucket           = var.s3_bucket
  
  # Auto Scaling Group Configuration
  asg_desired_capacity = var.asg_desired_capacity
  asg_max_size         = var.asg_max_size
  asg_min_size         = var.asg_min_size
  
  # Will be updated when ALB module is created
  target_group_arn     = ""

  # Common Tags
  common_tags = merge(
    {
      Team        = var.team_name
      Environment = var.environment
      Project     = var.project_name
      Terraform   = "true"
    },
    var.additional_tags
  )
}

# Security Groups
resource "aws_security_group" "web_sg" {
  name        = "${var.team_name}-${var.environment}-web-sg"
  description = "Security group for web servers"
  vpc_id      = module.network.vpc_id

  # Allow HTTP from internet
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from internet
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from bastion host
  ingress {
    description     = "Allow SSH from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.team_name}-${var.environment}-web-sg"
    Environment = var.environment
    Team        = var.team_name
    Project     = "ACS730"
    Terraform   = "true"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.team_name}-${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = module.network.vpc_id

  # Allow SSH from admin IP
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.team_name}-${var.environment}-bastion-sg"
    Environment = var.environment
    Team        = var.team_name
    Project     = "ACS730"
    Terraform   = "true"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "${var.team_name}-${var.environment}-private-sg"
  description = "Security group for resources in private subnets"
  vpc_id      = module.network.vpc_id

  # Allow SSH from bastion host
  ingress {
    description     = "Allow SSH from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Allow HTTP from web servers
  ingress {
    description     = "Allow HTTP from web servers"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # Allow HTTPS from web servers
  ingress {
    description     = "Allow HTTPS from web servers"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.team_name}-${var.environment}-private-sg"
    Environment = var.environment
    Team        = var.team_name
    Project     = "ACS730"
    Terraform   = "true"
  }
}
