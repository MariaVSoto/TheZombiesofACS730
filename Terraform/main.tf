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
  admin_ip_cidr     = var.admin_ip_cidr
  common_tags       = local.common_tags
}

# ALB Module (将在后续创建)
module "alb" {
  source = "./modules/alb"

  environment      = var.environment
  team_name       = var.team_name
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnet_ids
  common_tags     = local.common_tags
}

# Webserver Module
module "webserver" {
  source = "./modules/webserver"

  environment            = var.environment
  team_name             = var.team_name
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  bastion_sg_id         = module.network.bastion_sg_id
  alb_security_group_id = module.alb.alb_security_group_id
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  s3_bucket             = var.s3_bucket
  
  # Auto Scaling Group Configuration
  asg_desired_capacity = var.asg_desired_capacity
  asg_max_size         = var.asg_max_size
  asg_min_size         = var.asg_min_size
  
  target_group_arn     = module.alb.target_group_arn
  common_tags          = local.common_tags
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
