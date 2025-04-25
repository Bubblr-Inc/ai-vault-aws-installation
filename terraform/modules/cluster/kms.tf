module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.1.0"

  aliases               = ["eks/${var.name}"]
  description           = "${var.name} cluster encryption key"
  enable_default_policy = true
  key_owners            = [var.owners_arn]

  tags = var.tags
}