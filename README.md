# AI Vault Helm Chart.

##### Table of Contents  
[Summary](#Summary)

[AI Vault Architecture](#Architecture)

[Time to Install](#Time)

[Requirements](#Requirements)

[Security Statement](doc/SECURITYSTATEMENT.md)

[Prepare for your Installation](#Prepare%20for%20your%20installation)

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

### Config Requirements

To complete a successful instalation. You will need to supply the following configuration information.

| Config        | Description                                                     | Notes                             |
| --------------| ----------------------------------------------------------------|-----------------------------------|
| User URL      | The URL that admins / user will use to connect to the AI Vault  | a URL for your users to access. For example if your companies domain is `myorg.tld` you could use a URL such as ai-vault.myorg.tld.  |
| Database Host | The Host dns name endpoints that points to a POSTGRES database. | something like mydatabase.server.vpc - this may not exist yet and you would build it in the Infrastrucutre requirements section|
| Database user | A user on your database service instance e.g mypostgresuser ||
| Database password | The corresponding password belonging to the Database user||


### Skill Requirements
To install the AI-Vault helm chart a user will need experience of managing helm and kubernetes deployments in a EKS environment. Some experience of AWS RDS is needed to ensure that snapshots and backups are running successfully.

### Infrastructure Requirements

To successfully run  an AI-Vault instance the following components are required and you should expect to run these components (or their alternative - see note ) at a minimum to successfully run and AI instalation.

| Component       | Description                                                  | Info                            |
| --------------- | ------------------------------------------------------------ |---------------------------------|
| ALB Load balancer with TLS | The URL endpoint that users will access AI Vault. | Generated at Helm Chart Install|
| ACM TLS certifcate | AWS ACM certificate use for providing the TLS encryption. | User to create or supply and make a note of the ACM ARN. This acm certificate should cover the dns entry such as ai-vault.userdomain.com |
| DNS Entry | DNS entry pointing to the loadbalancer enpoint  | User to decide the url and then generate this after Helm Chart install at this time, post install, the chart should output the loadbalancer DNS CNAME. Something like ai-vault.userdomain.com as decided by the user|
| Kubernetes Cluster | Kubernetes cluster that will will run the AI Vault containers | User to create or supply and make a note of the cluster name|
| Node Pool |  A EKS node pool with at least one running instance of type t3large or above ||
| PostGres DataBase | A postgres database for the AI Vault containers to store data | Make a note of the server URL, you will need to supply this when installing the Helm chart|

[Costs Estimates can be found here:](doc/COST.md)

```
Note: You may choose to use a classic load balancer, traefik or Nginx load balancer for the Ingress,
and you may use your own managed Postgres or Kubernetes on raw EC2. However this is not covered in this guide. 
```

### Permissions requirements
[Permission Requirements are found here:](doc/INSTALLPERMISSIONS.md)

If you have these already prepared you may skip to the _Installation of the Helm chart_ section, otherwise continue to the
next section.
  
 ## Prepare for your installation
 If you already have the items listed in the requirements section such as AWS VPC, EKS cluster and an RDS database your simply need to make a note these and ensure you have kubernetes connection via kubectl and helm, a postgres database and a user that has sufficient access to create a database and supporting tables.

If you do not have the infrastructure components listed in the requirements section you will need to create them in your AWS account.
This can be done a number of ways however, we generally use terraform so to setup the infrastructure required by AI-Vault please use [this guide that describes how to do this](doc/INSTALL.md)

``` Note: This process generally takes around 1 hr to complete, although DNS propagation may take longer. ```

## Installation 
At this stage we assume you have the following:
1. Access to your AWS account via the account cli with permissions described here https://github.com/Bubblr-Inc/ai-vault-aws-installation/blob/main/doc/INSTALLPERMISSIONS.md
2. Permssion to install tools su
3. A running EKS Kubernetes Cluster and you have a note of its name.
4. A running RDS PostGres Database
5. Login credentials to RDS postres
6. Your URL such as ai-vault.myorg.tld

### Authenticate your command line 
Following the instructions here https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-authentication.html

### Install and Authenticate your kubectl amd eksctl tools
Install
eksctl: https://eksctl.io/installation

kubectl: https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html

Authenticate and register in kubeconfig file
```
aws eks update-kubeconfig --region region-code --name my-cluster
```

```
kubectl create namespace ai-vault-ns
            
eksctl create iamserviceaccount \
    --name ai-vault-sa \
    --namespace ai-vault-ns \
    --cluster <ENTER_YOUR_CLUSTER_NAME_HERE> \
    --attach-policy-arn arn:aws:iam::aws:policy/AWSMarketplaceMeteringFullAccess \
    --attach-policy-arn arn:aws:iam::aws:policy/AWSMarketplaceMeteringRegisterUsage \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AWSLicenseManagerConsumptionPolicy \
    --approve \
    --override-existing-serviceaccounts
```

### Authenticate to AWS ECR
Authenticate your Helm client to the Amazon ECR registry holding the AI Vault Helm Chart.

```
export HELM_EXPERIMENTAL_OCI=1

aws ecr get-login-password \
    --region us-east-1 | helm registry login \
    --username AWS \
    --password-stdin 709825985650.dkr.ecr.us-east-1.amazonaws.com
```

### Install the Helm Chart and supply your  values.
Install the chart to your kubernetes cluster. This example will install to the namespace ai-vault-ns
```
mkdir awsmp-chart && cd awsmp-chart

helm pull oci://709825985650.dkr.ecr.us-east-1.amazonaws.com/ethical-web-ai/ai-vault-helm --version 0.2.4

tar xf $(pwd)/* && find $(pwd) -maxdepth 1 -type f -delete

helm install ai-vault-helm-release \
    --set gpcBaseUrl=<YOUR DNS NAME e.g aivault.yourdomain.tld > \
    --set gptDataDbUser=<postgresuser> \
    --set mailFrom=<YOUREMAIL> \
    --set mailServerPort=<587> \
    --set mailServer=<YOUR MAILSERVER> \
    --set smtpLoginId=<YOUR MAIL SERVER LOGIN USER>
    --namespace ai-vault-ns ./* 
```

## Adding a Load Balancer via Ingress
The following example describes setting an ingress for an AWS ALB LoadBalancer.

1. Decide the hostname / url you wish to use to connect to your ai-vault instance. e.g ai-vault.mydomain.com
2. Create or  an ACM TLS Certificate https://docs.aws.amazon.com/res/latest/ug/acm-certificate.html. _Note_ if you are using an existing ACM the skip to the next step.

3. Make an a note of the ACM certifcates' ARN

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
    - host:
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
helm uninstall ai-vault-helm-release -n ai-vault-ns
```
## Backup And Restore
Please see the following section on backup and restore for AI-Vault database.
![Backup and Restore](doc/BACKUPRESTORE.md)

## Health Check
For health checks see the following section.
![Health Checks](doc/HEALTHCHECKS.md)
