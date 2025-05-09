module "cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = var.name
  engine         = "aurora-postgresql"
  engine_version = "14.6"
  instance_class = var.instance_class
  instances = {
    one = {}
    1 = {
      instance_class = var.instance_class
    }
  }

  master_username = "postgresadmin"

  vpc_id               = var.vpc_id
  db_subnet_group_name = aws_db_subnet_group.default.name
  security_group_rules = {
    ex1_ingress = {
      cidr_blocks = [var.vpc_cidr]
    }
  }

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = var.tags
}

resource "aws_db_subnet_group" "default" {
  name       = "ai-vault"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.name} DB subnet group"
  }
}

#output "eks_cluster_endpoint" {
#  value = "${module.cluster.cluster_endpoint}"
#}

output "cluster_master_username" {
  value = "${module.cluster.cluster_master_username}"
}

output "cluster_master_password" {
  value = "${module.cluster.cluster_master_password}"
}
