# Installating with with Terraform

The following example will start with an empty AWS account and will build AI Vault installation.

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

## Clone this repo
Clone this repository to your AWS authenticated workstation / laptop.
https://github.com/Bubblr-Inc/ai-vault-infra-template
