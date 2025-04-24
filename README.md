# AI Vault Helm Chart.

##### Table of Contents  
[Summary](#Summary)

[AI Vault Architecture](#Architecture)

[Time to Install](#Time)

[Requirements](#Requirements)

[Security Statement](doc/SECURITYSTATEMENT.md)

[Infrastructure Installation](doc/README-WORKED-INSTALL-TF.md)

[Installing the Chart](#Installation)


## Summary
This chart is used to install the AI vault and AI Vault Entity Extraction Deployments.

## Architecture
The architecture of AI seek is a fairly simple one, consisting of an edge ingress via a load balancer, a kubernetes deployment and a database.  In AWS terms this commonly means an AWS VPC, ALB load balancer, an EKS kubernetes cluster and a Postgres database.  This is the architecture that is generally recommended to run AI-Vault as it is well tested and runs well across a multi AZ

![Ai-Vault on EKS Architecture](doc/AI-Vault-Architecture-Diagram-v1.png?raw=true "Title")

### High Availablilty
This solution uses VPC with multi A-Z setup on both the EKS compute layer and the RDS Postgres layer to provide a resiliant setup. 

### Supported AWS Regions
| NA       | EU |
| --------------- | ------------- |
| us-east-1 | eu-west-1
|us-east-2|eu-west-2
|us-west-1|eu-west-3
|us-west-2|eu-central-1|
|ca-central-1 ||
|ca-west-1	 | |

## Time
30 Mins For the Chart Alone up to several hours if you need to install the supporting infrastructure.

This varies depending on your environment - for example if you have an existing EKS Kubernetes installation this will cut the time off by at least 40%.
To build the system with all of the components: vpc, eks, rds and the helm chart install can take around 2-3 hrs.

## Requirements

### Skill Requirements
To install the AI-Vault helm chart a user will need experience of managing helm and kubernetes deployments in a EKS environment. Some experience of AWS RDS is needed to ensure that snapshots and backups are running successfully.

### Infrastructure Requirements

To successfully run  an AI-Vault instance the following components are required and you should expect to run these components (or their alternative - see note ) at a minimum to successfully run and AI instalation.

| Component       | Description |
| --------------- | ------------- |
| ALB Load balancer with TLS | The URL endpoint that users will access AI Vault.     |Generated at Helm Chart Install|
| ACM TLS certifcate | AWS ACM certificate use for providing the TLS encryption. | Generate and make a note of the ACM ARN |
| DNS Entry | DNS entry pointing to the loadbalancer enpoint  |Generate this after Helm Chart Install when you have the loadbalancer CNAME|
| Kubernetes Cluster | Kubernetes cluster that will will run the AI Vault containers |Make a note of the cluster name|
| Node Pool |  A EKS node pool with at least one running instance of type t3large or above |
| PostGres DataBase | A postgres database for the AI Vault containers to store data |]Make a note of the server URL|

[Costs Estimates can be found here:](doc/COST.md)

```
Note: You may choose to use a classic load balancer, traefik or Nginx load balancer for the Ingress,
and you may use your own managed Postgres or Kubernetes on raw EC2. However this is not covered in this guide. 
```
#### Permissions requirements
| Permission       | Description | Mandatory|
|------------------|-------------|----------|
|Access Entry to EKS|To install the AI-Vault helm chart a user needs cli access to the EKS cluster with the kubernetes kubectl tool.  This is most commonly done by adding an access entry to your EKS cluster. https://docs.aws.amazon.com/eks/latest/userguide/creating-access-entries.html|yes|
|"eks:*", "ssm:GetParameter", "ssm:GetParameters",  "kms:CreateGrant", "kms:DescribeKey"|Only if you need to build an EKS cluster|no|
|"iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile", "iam:RemoveRoleFromInstanceProfile","iam:GetRole", "iam:CreateRole", "iam:DeleteRole", "iam:AttachRolePolicy", "iam:PutRolePolicy", "iam:UpdateAssumeRolePolicy", "iam:AddRoleToInstanceProfile", "iam:ListInstanceProfilesForRole", "iam:PassRole", "iam:DetachRolePolicy", "iam:DeleteRolePolicy", "iam:GetRolePolicy", "iam:GetOpenIDConnectProvider", "iam:CreateOpenIDConnectProvider", "iam:DeleteOpenIDConnectProvider", "iam:TagOpenIDConnectProvider", "iam:ListAttachedRolePolicies", "iam:TagRole", "iam:UntagRole", "iam:GetPolicy", "iam:CreatePolicy", "iam:DeletePolicy", "iam:ListPolicyVersions"|Only if you need to build an EKS cluster|no|
|AmazonEC2FullAccess|Only if you need to build a EKS, VPC and Subnets cluster|no|
|"rds:ModifyDBInstance","rds:CreateDBSnapshot","rds:CreateDBInstance","rds:Describe*"|Only if you need to build an RDS cluster|no|


If you have these already prepared you may skip to the _Installation of the Helm chart_ section, otherwise continue to the
next section.
  
 ## Prepare for your installation.
 If you already have the items listed in the requirements section such as AWS VPC, EKS cluster and an RDS database your simply need to make a note these and ensure you have kubernetes connection via kubectl and helm, a postgres database and a user that has sufficient access to create a database and supporting tables.

If you do not have the listed 
This can be done a number of ways however, we generally use terraform so to setup the infrastructure required by AI-Vault please use [this guide that describes how to do this](doc/README-WORKED-INSTALL-TF.md)

``` _Note_ This process generally takes around 1 hr to complete, although DNS propagation may take longer. ```

## Installation 

1. Prepare a values file for your installation.
Create a file names `customValues.yaml` containing the following values. Note, you will modify the environment variables to suit your environment.
_NOTE_ You will likely need an ALB Load Balancer to expose your Vault Endpoint see the _Adding a Load Balancer via Ingress_ section for details

```
namespace: ai-vault-ns
env:
  gpcBaseUrl: ""
  gptDataDbUser: ""
  gptDataDbHost: ""
  gptDataDbName: ""
  mailFrom: " support@bubblr.com"
  mailServer: "smtp.office.365.com"
  mailServerPort: "587"
  smtpLoginId: "support@bubblr.com"
```

### Authenticate to AWS ECR
Authenticate your Helm client to the Amazon ECR registry holding the AI Vault Helm Chart.

```
aws ecr get-login-password \
     --region eus-west-2 | helm registry login \
     --username AWS \
     --password-stdin 475755457693.dkr.ecr.eu-west-2.amazonaws.com
```

### Install the Helm Chart with your newly created values file.
Install the chart to your kubernetes cluster. This example will install to the namespace ai-vault-ns
```
helm install --create-namespace \
-n ai-vault-ns \
ai-vault-helm oci://475755457693.dkr.ecr.eu-west-2.amazonaws.com/ai-vault-helm \
--version 0.1.0 --values ./customValues.yaml
```

## Adding a Load Balancer via Ingress
The following example describes setting an ingress for an AWS ALB LoadBalancer.

1. Decide the hostname / url you wish to use to connect to your ai-vault instance. e.g ai-vault.mydomain.com
2. Create or  an ACM TLS Certificate https://docs.aws.amazon.com/res/latest/ug/acm-certificate.html. _Note_ if you are using an existing ACM the skip to the next step.

3. Make an a note of  the ACM certifcates' ARN

4. Make a note of your public subnets ids.

5. Add an ingress section like the example below, replace the public subnets and certificate ARN with your own values estblished from the previous steps.  The line  `alb.ingress.kubernetes.io/subnets` needs a comma seperated list of subnets representing your environment and the line `alb.ingress.kubernetes.io/certificate-arn` needs the ARN of your ACM certificate. The ACM certificates should be in the same AWS region as your EKS cluster you are deploying the helm chart to.

```
ingress:
  enabled: true
  className: "alb"
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/healthcheck-path: /v1/client/health
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/subnets: subnet-1234567,subnet-89011123,subnet-141516171 #replace with your own public subnets
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:eu-west-1:123456789:certificate/50d7e14a-2345-4241-4567-d8d208f22b67 #replace with your own ACM Certificate ARN
    alb.ingress.kubernetes.io/group.name: ai-vault
    alb.ingress.kubernetes.io/load-balancer-name: ai-vault
  hosts:
    - host: ai-vault.prodsvc.com
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: ai-vault-svc
              port:
                number: 80
```

### Uninstall Helm Chart
```
helm uninstall ai-vault-helm -n ai-vault-ns
```
## Backup And Restore
Please see the following section on backup and restore for AI-Vault database.
![Backup and Restore](doc/BACKUPRESTORE.md)

## Health Check
For health checks see the following section.
![Health Checks](doc/HEALTHCHECKS.md)
