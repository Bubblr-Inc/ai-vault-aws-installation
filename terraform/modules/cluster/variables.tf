
variable "vpc_id" {}

variable "name" {}

variable "aws_account_id" {}

variable "aws_region" {}

variable "environment" {}

variable "tags" {
  type        = map(string)
  description = "Tags for Infra"
}

variable "private_subnets" {}

variable "public_subnets" {}

variable "key_owners_arn" {}

variable "random_string" {}

variable "instance_types" {
  default = [
    "t3.medium"
  ]
}
