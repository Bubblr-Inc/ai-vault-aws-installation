# AI Vault Helm Chart.
## Summary
This chart is used to install the AI vault and AI Vault Entity Extraction Deployments.

## Requirements
To successfully run and install an AI-Vault instance the following components are required:

| Component       | Description |
| --------------- | ------------- |
| Load balancer with TLS | The URL endpoint that users will access AI Vault.     |
| DNS Entry | A DNS entry pointing to the loadbalancer enpoint  |
| Kubernetes Cluster | Kubernetes cluster will run the AI Vault containers |
| PostGres DataBase | A postgres database for the AI Vault containers to store data |

If you have these already prepared you may skip to the _Installation of the Helm chart_ section, otherwise continue to the
next section.

## Security Statement

### Resources
- AI Helm chart is installed on AWS EKS. the AI workload need access to and RDS postgres database only.
- A public load balancer is required to publish the AI-Vault URL.
- No public access to S3 is required for the installation.

### Customer Data
 - Customer data is limited to a users e-mail address.  This address is stored in an encrypted format in the database this database will be encrypted by default.

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
## Development
### Testing Rendered Templates

To view and test the output of your templates without installing it to your Kubernetes cluster run the following instructions:

1. If you haven't already clone this repo to your workstation or laptop.
   ```
   git clone https://github.com/Bubblr-Inc/ai-vault-helm.git
   ```
2. Change directory into the the helm repo chart directory
   ```
   cd ai-vault-helm
   ```
3. Run the helm debug command
```
helm template ai-vault-helm .
```


### Packaging and Pushing Helm Chart
1. Create helm package package
-  From the directory above the repo create
```
helm package ai-vault-helm
```
Make a note of the outputted package something like ai-vault-helm-0.1.0.tgz
2. Authenticate to AWS ECR

   ```
aws ecr get-login-password --region eu-west-2 |  helm registry login --username AWS --password-stdin <accountID>.dkr.ecr.eu-west-2.amazonaws.com
   ```

3. Push to AWS ECR HELM
Replace the version with the package created in the Create helm package step

```
helm push ai-vault-helm-<VERSION>.tgz oci://<accountID>.dkr.ecr.eu-west-2.amazonaws.com/
```

4. Verfiy the helm chart has been pushed correctly
```
aws ecr describe-images \
     --repository-name ai-vault-helm \
     --region eu-west-2
```
