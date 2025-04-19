provider "aws" {
  region = "eu-west-1" #Change this to your region
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  aws_account_id = "1234567890" # Change to your AWS Account
  name          = "MyAIVault" # Optionally change the name to something to suit you
  vpc_cidr       = "172.22.0.0/16" # Optionally change this to a RFC1818 Cidr
  aws_region     = "eu-west-1" # Change this to the AWS region you want run your AI-Vault in.
  tags = {
    Project    = local.name
  }
}

module "bootstrap" {
  source = ../modules/bootstrap"
  name = local.project_name
  environment = local.environment
  vpc_cidr = local.vpc_cidr
  azs = local.azs
  tags = local.tags
  ssm_ami = local.ssm_ami
}

module "database" {
  source = "../modules/database"
  vpc_id = module.outputs.vpc_id
  vpc_cidr = local.vpc_cidr
  name = local.name
  aws_account_id = local.aws_account_id
  environment = local.environment
  tags = local.tags
  aws_region = local.aws_region
}

module "cluster" {
  source = "../modules/cluster"
  vpc_id = module.bootstrap.outputs.vpc_id
  name = local.name
  aws_account_id = local.aws_account_id
  environment = local.environment
  tags = local.tags
  private_subnets = module.bootstrap.outputs.private_subnets
  public_subnets = module.bootstrap.outputs.public_subnets
  key_owners_arn = data.aws_caller_identity.current.arn
  aws_region = local.aws_region
  random_string = module.bootstrap.outputs.random_string
}
