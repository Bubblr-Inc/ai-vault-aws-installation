
variable "vpc_id" {}

variable "name" {
  default = "ai-vault"
}

variable "aws_account_id" {}

variable "aws_region" {}

variable "tags" {
  type        = map(string)
  description = "Tags for Infra"
}

variable "private_subnets" {}

variable "public_subnets" {}

variable "owners_arn" {}

variable "random_string" {}

variable "instance_types" {
  default = [
    "t3.medium"
  ]
}
