# Installing with with Terraform

The following example will start with an empty AWS account and will build AI Vault installation.

## Requirements
- An AWS account
- AWS cli installed on your laptop or workstatiopn
- Terraform client installed on your laptop

## The following operations will be performed
1. Create a VPC and three sets of subnets public, private and database.
2. Create a Route53 Zone.
3. Create an RDS Aurora PostGres Cluster.
4. Create an ACM certificate.
5. Create an EKS Cluster.
6. Install the Ai-Vault Helm chart.


## Install and authenticate the AWS cli
We need the AWS cli tool to authenticate terraform so this needs to be installed on the laptop or workstation on your machine.

AWS provides at least two methods to authenticate the CLI, via IAM keys and via SSO. Please follow this (aws provided) guide to authenticate to your AWS account:

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

_Note_ Please ensure you are not using the root AWS account for this operation.

Once you are authenticated move on to the next step below.

## Install the Terraform Binary
Install the terraform binary.  Instructions on how to do this can be found here:
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

## Clone this repo
Clone this repository to your AWS authenticated workstation / laptop.
[https://github.com/Bubblr-Inc/ai-vault-aws-installation](https://github.com/Bubblr-Inc/ai-vault-aws-installation)

## Edit terraform main.tf 
`main.tf` is the terraform where you set the variables to specify the attributes for your particular environment. In this step we will modify the file to suit your environment.

Navigate to the repo and open it in your preferred code editor such as Visual Studio Code or Notepad++.

Within the terraform directory open the main.tf for editing.

```
locals {
  aws_account_id = "1234567890" # Change to your AWS Account
  name          = "MyAIVault" # Optionally change the name to something to suit you
  vpc_cidr       = "172.22.0.0/16" # Optionally change this to a RFC1818 Cidr
  aws_region     = "eu-west-1" # Change this to the AWS region you want run your AI-Vault in.
  tags = {
    Project    = local.name
  }
}
```

There are two mandatory options to change:

1. The aws_account_id.  This is the unique account ID associated with your AWS.
2. The aws_region. You should set this to match the region you wish to run in. For example, eu-west-1 (the default) with run in the EU Ireland region.

## Run Terraform init

