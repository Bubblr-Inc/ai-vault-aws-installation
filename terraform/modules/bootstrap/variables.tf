
variable "name" {}

variable "environment" {}

variable "vpc_cidr" {}

variable "azs" {}

variable "tags" {
  type        = map(string)
  description = "Tags for Infra"
}

variable "ssm_ami" {}
