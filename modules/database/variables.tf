
variable "vpc_id" {}

variable "name" {}

variable "aws_account_id" {}

variable "aws_region" {}

variable "environment" {}

variable "tags" {
  type        = map(string)
  description = "Tags for Infra"
}

variable "vpc_cidr" {}

variable "instance_class" {
  default = "db.t3.large"
}
