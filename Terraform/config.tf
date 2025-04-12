provider "aws" {
  region = var.region
}


terraform {
  backend "s3" {
    bucket = var.terraform_state_bucket
    key    = var.terraform_state_key
    region = var.region
  }
}