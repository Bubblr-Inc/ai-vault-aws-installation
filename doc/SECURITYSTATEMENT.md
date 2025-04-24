## Security Statement
### Resources
- AI Helm chart doesn't require the usage of the AWS root account. All installation and running processes use IAM roles and policies as recommended by AWS best practices.
- AI Helm chart is installed on AWS EKS. the AI workload need access to and RDS postgres database only.
- A public load balancer is required to publish the AI-Vault URL.
- No public access to S3 is required for the installation.

### Customer Data
 - Customer data stored by AI Vault is limited to a user's e-mail address.  This address is stored in an encrypted format in the database at the column level.  This RDS database will be encrypted at rest by default.

### Principal of Least Priviledge
- AI Vault containers require read and write access to a RDS postgres database only.  They do not require access to any other AWS resources and therefore do not need to run with a powerful IAM role.  Please ensure when setting up you do not inadvertantly assign unnecessary IAM permissions or roles.
