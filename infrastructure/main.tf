# main.tf
# Create a VPC via the official module, then create an EKS cluster with a managed node group.
# Comments prefixed with >>> explain reasoning.


# VPC: official terraform-aws-modules/vpc/aws

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "${var.cluster_name}-vpc"      # >>> friendly name referencing cluster
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = merge(var.resource_tags, { Name = "${var.cluster_name}-vpc" })
}


# EKS: official terraform-aws-modules/eks/aws

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.13.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # For quick demos we enable the public endpoint (convenient for kubeconfig).
  # >>> WARNING: For production, prefer private endpoint + API access via bastion/jump host or secure CI runners.
  cluster_endpoint_public_access = true

  # Networking integration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Managed node group configuration (single small node for cost control)
  eks_managed_node_groups = {
    default = {
      desired_capacity = var.desired_capacity
      max_capacity     = var.max_capacity
      min_capacity     = var.min_capacity

      instance_types = var.node_instance_types

      # Node group tags
      tags = merge(var.resource_tags, { Name = "${var.cluster_name}-ng" })
    }
  }

  # Manage the aws-auth configmap via the module so your IAM users get Kubernetes RBAC mapping.
  # The module will create the aws-auth configmap and map the listed IAM users to k8s subjects.
  manage_aws_auth_configmap = true
  aws_auth_users = var.aws_auth_users

  # Basic tags applied to cluster
  tags = merge(var.resource_tags, { Name = var.cluster_name })
}

