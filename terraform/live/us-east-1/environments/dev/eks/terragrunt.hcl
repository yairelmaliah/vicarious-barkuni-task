terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=20.17.2"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-1234567890abcdef01"
    private_subnets = ["subnet-1234567890abcdef01", "subnet-1234567890abcdef02"]
  }
}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment = local.env_vars.locals.environment
}

inputs = {
  cluster_name = local.env_vars.locals.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true
  
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }
  
  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  eks_managed_node_groups = {
    barkuni = {
      ami_type       = "AL2_x86_64"
      instance_types = ["m5.large"]

      min_size = 1
      max_size = 3
      desired_size = 1
    }
  }

  tags = local.env_vars.locals.tags
}

