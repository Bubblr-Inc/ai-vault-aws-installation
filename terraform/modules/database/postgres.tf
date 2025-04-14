module "cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = var.name
  engine         = "aurora-postgresql"
  engine_version = "14.5"
  instance_class = var.instance_class
  instances = {
    one = {}
    1 = {
      instance_class = var.instance_class
    }
  }

  vpc_id               = var.vpc_id
  db_subnet_group_name = "db-subnet-group"
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
