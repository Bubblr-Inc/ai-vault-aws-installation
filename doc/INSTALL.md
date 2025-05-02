# 


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

## Edit terraform main.tf (Optional or except the defaults)
`main.tf` is the terraform where you set the variables to specify the attributes for your particular environment. In this step we will modify the file to suit your environment.

Navigate to the repo and open it in your preferred code editor such as Visual Studio Code or Notepad++.

Within the terraform directory open the main.tf for editing.

```
locals {
  aws_account_id = data.aws_caller_identity.current.account_id 
  name          = "MyAIVault" # Optionally change the name to something to suit you
  vpc_cidr       = "172.22.0.0/16" # Optionally change this to a RFC1818 Cidr
  aws_region     = "eu-west-1" # Optionally Change this to the AWS region you want run your AI-Vault in.
  tags = {
    Project    = local.name
  }
}
```

There are two mandatory options to change:

1. The aws_account_id.  This is the unique account ID associated with your AWS.
2. The aws_region. You should set this to match the region you wish to run in. For example, eu-west-1 (the default) with run in the EU Ireland region.

## Setup a Terraform State Bucket (Optional but recommended)
Create an S3 bucket to keep the state of your set up so you can run terraform commands from other workstations or CI/CD processes.

https://developer.hashicorp.com/terraform/language/backend/s3

Add the state bucket declaration in the main.tf file, something like the following:
```
terraform {
  backend "s3" {
    bucket = "myaivault.tfstate.bucket"
    key    = terraform.tfstate"
    region = "eu-west-1"
  }
}
```

## Run Terraform init
Terraform init sets up the terrafrom environment within this directory and will download and required terraform providers.
From within the terraform directory type the following :
```
terrafrom init
```
which should provide the following output
```
$ tf init
Initializing the backend...
Initializing modules...
- bootstrap in modules/bootstrap
Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 5.21.0 for bootstrap.vpc...
- bootstrap.vpc in .terraform/modules/bootstrap.vpc
- cluster in modules/cluster
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 20.34.0 for cluster.eks...
- cluster.eks in .terraform/modules/cluster.eks
- cluster.eks.eks_managed_node_group in .terraform/modules/cluster.eks/modules/eks-managed-node-group
- cluster.eks.eks_managed_node_group.user_data in .terraform/modules/cluster.eks/modules/_user_data
- cluster.eks.fargate_profile in .terraform/modules/cluster.eks/modules/fargate-profile
Downloading registry.terraform.io/terraform-aws-modules/kms/aws 2.1.0 for cluster.eks.kms...
- cluster.eks.kms in .terraform/modules/cluster.eks.kms
- cluster.eks.self_managed_node_group in .terraform/modules/cluster.eks/modules/self-managed-node-group
- cluster.eks.self_managed_node_group.user_data in .terraform/modules/cluster.eks/modules/_user_data
Downloading registry.terraform.io/terraform-aws-modules/kms/aws 1.1.0 for cluster.kms...
- cluster.kms in .terraform/modules/cluster.kms
Downloading registry.terraform.io/terraform-aws-modules/iam/aws 5.55.0 for cluster.load_balancer_controller_irsa_role...
- cluster.load_balancer_controller_irsa_role in .terraform/modules/cluster.load_balancer_controller_irsa_role/modules/iam-role-for-service-accounts-eks
- database in modules/database
Downloading registry.terraform.io/terraform-aws-modules/rds-aurora/aws 9.13.0 for database.cluster...
- database.cluster in .terraform/modules/database.cluster
Initializing provider plugins...
- Finding hashicorp/cloudinit versions matching ">= 2.0.0"...
- Finding hashicorp/null versions matching ">= 3.0.0"...
- Finding hashicorp/aws versions matching ">= 3.72.0, >= 4.0.0, >= 4.33.0, >= 5.79.0, >= 5.83.0, >= 5.89.0"...
- Finding latest version of hashicorp/random...
- Finding latest version of hashicorp/kubernetes...
- Finding hashicorp/tls versions matching ">= 3.0.0"...
- Finding hashicorp/time versions matching ">= 0.9.0"...
- Installing hashicorp/kubernetes v2.36.0...
- Installed hashicorp/kubernetes v2.36.0 (signed by HashiCorp)
- Installing hashicorp/tls v4.1.0...
...
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
If this line is found near the bottom, this is a good sign.
```
Terraform has been successfully initialized!

```
## Run the Terraform plan command
```
terraform plan
```
