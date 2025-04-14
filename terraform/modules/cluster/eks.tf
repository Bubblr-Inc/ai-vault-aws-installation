module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name = var.name

  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # External encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }

  eks_managed_node_groups = {
    app_nodes = {
      name            = var.name
      use_name_prefix = true

      subnet_ids = var.private_subnets

      min_size     = 1
      max_size     = 5
      desired_size = 3

      capacity_type  = "ON_DEMAND"
      instance_types = var.instance_types

      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      description = "App Node Group"
    }
  }
}
