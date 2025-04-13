terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }
  required_version = ">= 0.14"
}

# IAM Role
resource "aws_iam_role" "lab_role" {
  name = "LabRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "lab_role_policy" {
  name = "LabRolePolicy"
  role = aws_iam_role.lab_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "s3:*",
          "vpc:*",
          "iam:*",
          "autoscaling:*",
          "cloudwatch:*",
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "lab_profile" {
  name = "LabProfile"
  role = aws_iam_role.lab_role.name
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
  common_tags       = var.common_tags
}

# ALB Module
module "alb" {
  source = "./modules/ALB"

  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  environment           = var.environment
  team_name            = var.team_name
  alb_security_group_id = module.network.alb_security_group_id
  common_tags          = var.common_tags
  enable_https         = false
}

# Webserver Module
module "webserver" {
  source = "./modules/webserver"

  environment           = var.environment
  team_name             = var.team_name
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  instance_type         = var.instance_type
  key_name              = var.key_name
  ami_id                = var.ami_id
  common_tags           = var.common_tags
  additional_tags       = var.additional_tags
  bastion_sg_id         = module.network.bastion_security_group_id
  s3_bucket             = var.s3_bucket
  region = var.region
  
  bastion_subnet_index = var.bastion_subnet_index
  web4_subnet_index    = var.web4_subnet_index
  web5_subnet_index    = var.web5_subnet_index
  vm6_subnet_index     = var.vm6_subnet_index

  # Auto Scaling Group Configuration
  asg_desired_capacity = var.asg_desired_capacity
  asg_max_size         = var.asg_max_size
  asg_min_size         = var.asg_min_size
}

# Local values
locals {
  common_tags = merge(
    {
      Team        = var.team_name
      Environment = var.environment
      Project     = var.project_name
      Terraform   = "true"
      CostCenter  = var.cost_center
      Owner       = var.owner
      ManagedBy   = var.managed_by
    },
    var.additional_tags
  )
}
