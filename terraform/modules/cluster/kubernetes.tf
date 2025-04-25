
locals {
  current_user_arn = var.owners_arn
  user_type = length(regexall("role", local.current_user_arn)) > 0 ? "role" : "user"
  user = split("/", local.current_user_arn )[1]
  principal_arn = "arn:aws:iam::${var.aws_account_id}:${local.user_type}/${local.user}"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

resource "aws_eks_access_policy_association" "administrators" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = local.principal_arn
  access_scope {
    type       = "cluster"
  }
}

resource "aws_eks_access_entry" "current_user_access" {
  cluster_name      = module.eks.cluster_name
  principal_arn     =  local.principal_arn
  kubernetes_groups = []
  type              = "STANDARD"
}

