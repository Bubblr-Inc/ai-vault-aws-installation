### Permissions requirements
The following lists the AWS accounts the user's credentials will need when running the install.
| Permission       | Description | Mandatory|
|------------------|-------------|----------|
|Access Entry to EKS|To install the AI-Vault helm chart a user needs cli access to the EKS cluster with the kubernetes kubectl tool.  This is most commonly done by adding an access entry to your EKS cluster. https://docs.aws.amazon.com/eks/latest/userguide/creating-access-entries.html|yes|
|"eks:*", "ssm:GetParameter", "ssm:GetParameters",  "kms:CreateGrant", "kms:DescribeKey"|Only if you need to build an EKS cluster|no|
|"iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile", "iam:RemoveRoleFromInstanceProfile","iam:GetRole", "iam:CreateRole", "iam:DeleteRole", "iam:AttachRolePolicy", "iam:PutRolePolicy", "iam:UpdateAssumeRolePolicy", "iam:AddRoleToInstanceProfile", "iam:ListInstanceProfilesForRole", "iam:PassRole", "iam:DetachRolePolicy", "iam:DeleteRolePolicy", "iam:GetRolePolicy", "iam:GetOpenIDConnectProvider", "iam:CreateOpenIDConnectProvider", "iam:DeleteOpenIDConnectProvider", "iam:TagOpenIDConnectProvider", "iam:ListAttachedRolePolicies", "iam:TagRole", "iam:UntagRole", "iam:GetPolicy", "iam:CreatePolicy", "iam:DeletePolicy", "iam:ListPolicyVersions"|Only if you need to build an EKS cluster|no|
|AmazonEC2FullAccess|Only if you need to build a EKS, VPC and Subnets cluster|no|
|"rds:ModifyDBInstance","rds:CreateDBSnapshot","rds:CreateDBInstance","rds:Describe*"|Only if you need to build an RDS cluster|no|
