provider "aws" {
  region = "eu-west-1" #Change this to your region
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id 
  name          = "test-ai-vault" # Optionally change the name to something to suit you (lower case and hyphens only_)
  vpc_cidr       = "172.22.0.0/16" # Optionally change this to a RFC1818 Cidr
  aws_region     = "eu-west-1" # Change this to the AWS region you want run your AI-Vault in.
  tags = {
    Project    = local.name
  }
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "bootstrap" {
  source = "./modules/bootstrap"
  name = local.name
  vpc_cidr = local.vpc_cidr
  azs = local.azs
  tags = local.tags
}

module "database" {
  source = "./modules/database"
  vpc_id = module.bootstrap.vpc_id
  vpc_cidr = local.vpc_cidr
  name = local.name
  aws_account_id = local.aws_account_id
  tags = local.tags
  aws_region = local.aws_region
  private_subnets = module.bootstrap.private_subnets
}

module "cluster" {
  source = "./modules/cluster"
  vpc_id = module.bootstrap.vpc_id
  name = local.name
  aws_account_id = local.aws_account_id
  tags = local.tags
  private_subnets = module.bootstrap.private_subnets
  public_subnets = module.bootstrap.public_subnets
  owners_arn = data.aws_caller_identity.current.arn
  aws_region = local.aws_region
  random_string = module.bootstrap.random_string
}

output "public_subnets" {
  value = "${module.bootstrap.public_subnets}"
}

output "eks_cluster_name" {
  value = module.cluster.cluster_name
}

#output "database_cluster_endpoint" {
#  value = "${module.database.cluster_endpoint}"
#}

output "cluster_master_username" {
  value = "${module.database.cluster_master_username}"
}

output "cluster_master_password" {
  value = "${module.database.cluster_master_password}"
  sensitive = true
}


terraform {
  backend "s3" {
    bucket = "ai-vault-tester-tf"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
