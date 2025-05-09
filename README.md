# AI Vault Helm Chart.

##### Table of Contents  
[Summary](#Summary)

[AI Vault Architecture](#Architecture)

[Time to Install](#Time)

[Requirements](#Requirements)

[Security Statement](doc/SECURITYSTATEMENT.md)

[Prepare for your Installation](#Prepare-for-your-installation)

[Installing the Chart](#Installation)

[Initialising your installation](#initialising-your-installation)


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

To complete a successful instalation. You will need to supply the following configuration information:

| Config        | Description                                                     | Notes                             |
| --------------| ----------------------------------------------------------------|-----------------------------------|
| Your AI Vault URL     | The URL that admins / user will use to connect to the AI Vault  | a URL for your users to access. For example if your companies domain is `myorg.tld` you could use a URL such as ai-vault.myorg.tld.  |
| Database Host | The Host dns name endpoints that points to a POSTGRES database. | something like mydatabase.server.vpc - this may not exist yet and you would build it in the Infrastrucutre requirements section|
| Database user | A user on your database service instance e.g mypostgresuser ||
| Database password | The corresponding password belonging to the Database user||

you will also need to supply an AWS region eg: eu-west-1

### Skill Requirements
To install the AI-Vault helm chart a user will need experience of managing helm and kubernetes deployments in a EKS environment. Some experience of AWS RDS is needed to ensure that snapshots and backups are running successfully.

### Infrastructure Requirements

To successfully run  an AI-Vault instance the following components are required and you should expect to run these components (or their alternative - see note ) at a minimum to successfully run and AI instalation.

| Component       | Description                                                  | Info                            |
| --------------- | ------------------------------------------------------------ |---------------------------------|
| ALB Load balancer with TLS | Your Ai Vault URL | Generated at Helm Chart Install|
| ACM TLS certifcate | AWS ACM certificate use for providing the TLS encryption. | User to create or supply and make a note of the ACM ARN. This acm certificate should cover the dns entry such as ai-vault.userdomain.com |
| DNS Entry | DNS entry pointing to the loadbalancer enpoint  | User to decide the url and then generate this after Helm Chart install at this time, post install, the chart should output the loadbalancer DNS CNAME. Something like ai-vault.userdomain.com as decided by the user|
| Kubernetes Cluster | Kubernetes cluster that will will run the AI Vault containers | User to create or supply and make a note of the cluster name|
| Node Pool |  A EKS node pool with at least one running instance of type t3large or above ||
| PostGres DataBase | A postgres database for the AI Vault containers to store data | Make a note of the server URL, you will need to supply this when installing the Helm chart|
| An email address to send from | E.g supprt@myorg.com ||
| A Login account to send e-mails from your email address||

[Costs Estimates can be found here:](doc/COST.md)

```
Note: You may choose to use a classic load balancer, traefik or Nginx load balancer for the Ingress,
and you may use your own managed Postgres or Kubernetes on raw EC2. However this is not covered in this guide. 
```

### Permissions requirements
[Permission Requirements are found here:](doc/INSTALLPERMISSIONS.md)

If you have all of the infrastrucuture requirements already prepared you may skip to the _Installation of the Helm chart_ section, otherwise continue to the next section.
  
 ## Prepare for your installation
 If you already have the items listed in the requirements section such as AWS VPC, EKS cluster and an RDS database your simply need to make a note these and ensure you have kubernetes connection via kubectl and helm, a postgres database and a database user that has sufficient access to create a schemas and supporting tables.

If you do not have the infrastructure components listed in the requirements section you will need to create them in your AWS account.
This can be done a number of ways however, we generally use terraform to setup the infrastructure required by AI-Vault please use [this guide that describes how to do this](doc/INSTALL.md)

``` Note: This process generally takes around 1 hr to complete, although DNS propagation may take longer. ```

### Install and Authenticate the AWS CLI.
Follow the instructions here 
https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

## Installation 
At this stage we assume you have the following:
1. Access to your AWS account via the account cli with permissions described here https://github.com/Bubblr-Inc/ai-vault-aws-installation/blob/main/doc/INSTALLPERMISSIONS.md
2. Permssion to install tools.
3. A running EKS Kubernetes Cluster and you have a note of its name. This maybe the one you have already or one you built in the the "Preparing for intallation" step. See the outputs at the end of the the Preparing for the installation steps "eks_cluster_name".
   
5. A running PostGres Database.  Like the EKS cluster, this can be an existing one, or one you create in the "Preparing for intallation" step. See the outputs at the end of the the Preparing for the installation steps "database_cluster_endpoint".
6. A Database user and postgres.  This needs to be powerful enough to create schemas and tables.
7. The Ids of your Public subnets. These can be existing ones or the ones create in the "Preparing for intallation" step. See the outputs at the end of the the Preparing for the installation steps "public_subnets".
8. Your URL such as ai-vault.myorg.tld
9. E-mail address and Login Credentials for your e-mail

### Install and Authenticate your kubectl amd eksctl tools
Installation Instructions:
eksctl: https://eksctl.io/installation

kubectl: https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html

Authenticate and register in kubeconfig file
```
aws eks update-kubeconfig --region <YOU REGION CODE > --name <MY EKS CLUSTER NAME>
```

### Create a IAM policy for license management 
Create an IAM policy license - we will attach this to the ai-vault-sa in the next step.
Clone this repository 
```
git clone git@github.com:Bubblr-Inc/ai-vault-aws-installation.git
```
change to this repo directory
```
cd ai-vault-installation
```
create a new license policy
```
aws iam create-policy \
    --policy-name ai-vault-license-policy \
    --policy-document file://license-iam-policy.json
```

this should output something like this (below), make a note of the Arn value
```
{
    "Policy": {
        "PolicyName": "ai-vault-license-policy",
        "Arn": "arn:aws:iam::0123456789012:policy/ai-vault-license-policy",
    }
}
```

### Create an ai-vault namespace and add an ai-vault-sa service account
Here you are going to create the ai-vault namespace
```
kubectl create namespace ai-vault-ns
```
Now the service account, you will need to update the line that says and << REPLACE THIS WITH THE ARN CREATED IN THE PREVIOUS POLICY  with the ARN from the previous output. And update the --cluster < ENTER_YOUR_CLUSTER_NAME_HERE > With your cluster name e.g my-ai-vault
```
eksctl create iamserviceaccount \
    --name ai-vault-sa \
    --namespace ai-vault-ns \
    --cluster <ENTER_YOUR_CLUSTER_NAME_HERE> \
    --attach-policy-arn arn:aws:iam::aws:policy/AWSMarketplaceMeteringFullAccess \
    --attach-policy-arn arn:aws:iam::aws:policy/AWSMarketplaceMeteringRegisterUsage \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AWSLicenseManagerConsumptionPolicy \
    --attach-policy-arn arn:aws:iam::<YOU AWS ACCOUNT ID>:policy/ai-vault-license-policy \   << REPLACE THIS WITH THE ARN CREATED IN THE PREVIOUS POLICY
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
Install the chart to your kubernetes cluster. This example will install to the namespace ai-vault-ns created in the earlier step.
```
mkdir awsmp-chart && cd awsmp-chart

helm pull oci://709825985650.dkr.ecr.us-east-1.amazonaws.com/ethical-web-ai/ai-vault-helm --version 0.2.5

tar xf $(pwd)/* && find $(pwd) -maxdepth 1 -type f -delete
```
Edit the chart's built in values.yaml file, please modfiy the the following values : gpcBaseUrl, gptDataDbUser, gptDataDbHost
These are found in the env section. (Note - you can create a new values file called myValues.yaml or similar to over-ride the built in values file.  You will need to remember to supply this at the command line when you install the chart using the helm --values flag.

```
  gpcBaseUrl: "aivault.myorg.tld"  #Change this to your own value
  gptDataDbUser: "yourdbuser"     #Change this to the database user from the Running database
  gptDataDbHost: "yourdbhost" #change this to the postgres writer name
  gptDataDbName: "ai_vault"
  nlpApiUrl: "http://ai-vault-entity-svc/entities"
  mailFrom: "support@bubblr.com"
  mailServer: "smtp.office.365.com"
  mailServerPort: "587"
  smtpLoginId: "support@bubblr.com"
  aiSeekEnterPriseService: "https://aiseek-enterprise.production.prodsvc.com"
```

Add the sensitive values via kubernetes secrets:
The first one is the password for your database:
```
kubectl create secret generic gpt-data-db \
  --from-literal=password='<ENTER PASSWORD HERE>'
```
The second is the encryption key for your database.  This should be an random string of at least 16 characters. Hint: this command will create a random string for you: `openssl rand -base64 32`
```
 kubectl create secret generic encryption-key\
   --from-literal=key=<ENTER ENCRYPTION KEY HERE>
```
And finally your e-mail address password.
```   
 kubectl create secret generic support-smtp-login \
     --from-literal=id=<ENTER USER_ID> \
     --from-literal=password='<ENTER PASSWORD>'
```

Now install the chart
```
helm install ai-vault-helm-release --namespace ai-vault-ns ./* 
```

## Adding a Load Balancer via Ingress
The following example describes setting an ingress for an AWS ALB LoadBalancer.

1. Decide the hostname / url you wish to use to connect to your ai-vault instance. e.g ai-vault.mydomain.com
2. Create or  an ACM TLS Certificate https://docs.aws.amazon.com/res/latest/ug/acm-certificate.html. _Note_ if you are using an existing ACM the skip to the next step.

3. Make an a note of the ACM certifcates' ARN

4. Make a note of your public subnets ids. These can be found in the AWS console or via the AWS CLI command:
   ```aws ec2 describe-subnets --region <your region>```
6. Create a file called ingress.yaml

7. Add an ingress section to the ingress.yaml file like the example below, replace the public subnets and certificate ARN with your own values estblished from the previous steps.  The line  `alb.ingress.kubernetes.io/subnets` needs a comma seperated list of subnets representing your environment and the line `alb.ingress.kubernetes.io/certificate-arn` needs the ARN of your ACM certificate. The ACM certificates should be in the same AWS region as the EKS cluster you are deploying the helm chart to.

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
Retry the install command, note this time it says update, rather than install.
```
helm update ai-vault-helm-release --namespace ai-vault-ns ./* 
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

## Initialising your installation
During install you will recieve a link to your new login page. You can log in initially using the email address which you supplied as the initial user email. This user wll have superuser privileges. When you enter the email address and click login, you will recieve an email with a claim link. Simply click that link and you will be logged in. 


Before running any prompts you will need to get and enter an access key in order to validate your instance with the AI Seek Enterprise Engine. You can obtain a key by either sending an email direct to support@ethicalweb.ai and requesting a key or by using the contact form which is available from the app console once you are logged in. 


Enter the Access Key by selecting Account>Settings>Enter Access Key



