# AI Vault Helm Chart.
## Summary
This chart is used to install the AI vault and AI Vault Entity Extraction Deployments.

## AI Vault Architecture
The architecture of AI seek is a fairly simple one consisting of a edge ingress via load balancer, a kubernetes deployment and a database.  in AWS terms this comonnly means a AWS VPC, ALB load balancer, an EKS kubernetes cluster and a postgres database.  This is the architecture that AI-Vault is generally recommended as it is well tested and runs well across a multi AZ

![Ai-Vault on EKS Architecture](doc/AI-Vault-Architecture-Diagram-v1.png?raw=true "Title")

This solution 

## Requirements

### Skill Requirements

### Infrastructure Requirements

To successfully run  an AI-Vault instance the following components are required and you should expect to run these components (or their alternative - see note ) at a minimum to successfully run and AI instalation.

| Component       | Description |
| --------------- | ------------- |
| ALB Load balancer with TLS | The URL endpoint that users will access AI Vault.     |
| DNS Entry | A DNS entry pointing to the loadbalancer enpoint  |
| Kubernetes Cluster | Kubernetes cluster that will will run the AI Vault containers |
| Node Pool |  A EKS node pool with at least on running instance of type of t3_large or above |
| PostGres DataBase | A postgres database for the AI Vault containers to store data |

```
_Note_ You may choose to use a classic load balancer, traefik or Nginx load balancer for the Ingress,
and you may use your own managed Postgres or Kubernetes on raw EC2. However this is not covered in this guide. 
```

If you have these already prepared you may skip to the _Installation of the Helm chart_ section, otherwise continue to the
next section.

## Security Statement

### Resources
- AI Helm chart doesn't require the usage of the AWS root account. All installation and running processes use IAM roles and policies as recommended by AWS best practices.
- AI Helm chart is installed on AWS EKS. the AI workload need access to and RDS postgres database only.
- A public load balancer is required to publish the AI-Vault URL.
- No public access to S3 is required for the installation.

### Customer Data
 - Customer data stored by AI Vault is limited to a user's e-mail address.  This address is stored in an encrypted format in the database at the column level.  This RDS database will be encrypted at rest by default.

 ## Build or prepare the infrastructure.

This can be done a number of ways however, we generally use terraform so to setup the infrastrucutre required by AI-Vault please use [this guide that describes how to do this](doc/README-WORKED-INSTALL-TF.md)

## Installation of Helm Chart

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
