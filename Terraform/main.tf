terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }
  required_version = ">= 0.14"
}


module "network" {
  source = "./modules/network"

  environment        = var.environment
  team_name          = var.team_name
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  region             = var.region
}
module "alb" {
  source = "./modules/ALB"

  team_name            = var.team_name
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  alb_security_group_id = aws_security_group.alb_sg.id
  common_tags          = var.common_tags
  enable_https         = var.enable_https
  certificate_arn      = var.certificate_arn
}
