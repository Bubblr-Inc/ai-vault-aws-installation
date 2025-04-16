provider "aws" {
  region = "eu-west-1" #Change this to your region
}

locals {
  name           = "MyAIVault"
  aws_account_id = "1234567890"
  vpc_cidr       = "172.22.0.0/16"
  aws_region     = "eu-west-1"
  vpc_id = data.terraform_remote_state.bootstrap.outputs.vpc_id
  tags = {
    Project    = local.name
  }
  private_subnets = data.terraform_remote_state.bootstrap.outputs.private_subnets
  public_subnets = data.terraform_remote_state.bootstrap.outputs.public_subnets
}

module "postgres" {
  source = "../../modules/database"
  vpc_id = local.vpc_id
  vpc_cidr = local.vpc_cidr
  name = local.name
  aws_account_id = local.aws_account_id
  environment = local.environment
  tags = local.tags
  aws_region = local.aws_region
}
