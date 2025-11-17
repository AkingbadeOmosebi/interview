# main.tf
# Create a VPC via the official module, then create an EKS cluster with a managed node group.
# Comments prefixed with >>> explain reasoning.


# VPC: official terraform-aws-modules/vpc/aws
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "${var.cluster_name}-vpc" # >>> friendly name referencing cluster
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  # Required tags for EKS to discover subnets
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = merge(var.resource_tags, { Name = "${var.cluster_name}-vpc" })
}


# EKS: official terraform-aws-modules/eks/aws
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # For quick demos we enable the public endpoint (convenient for kubeconfig).
  cluster_endpoint_public_access = true

  # Networking integration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Node group configuration
  eks_managed_node_groups = {
    main = {
      desired_size = var.desired_capacity
      max_size     = var.max_capacity
      min_size     = var.min_capacity

      instance_types = var.node_instance_types

      labels = {
        role = "general"
      }

      tags = merge(var.resource_tags, { Name = "${var.cluster_name}-ng" })
    }
  }

  # Enable cluster creator admin permissions
  # This automatically grants the IAM principal creating the cluster admin access
  enable_cluster_creator_admin_permissions = true

  # Basic tags applied to the cluster
  tags = merge(var.resource_tags, { Name = var.cluster_name })
}


# AWS Auth ConfigMap Management
# >>> OFFICIAL DOCUMENTATION: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/20.37.2/submodules/aws-auth
# >>> In EKS module v20.x, aws-auth management is in a separate submodule
module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  # Enable management of the aws-auth ConfigMap
  manage_aws_auth_configmap = true

  # Map additional IAM users to Kubernetes RBAC groups
  # Format matches official documentation exactly
  aws_auth_users = var.aws_auth_users

  # Ensure EKS cluster is created before managing auth
  depends_on = [module.eks]
}
