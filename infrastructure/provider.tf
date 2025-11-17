# provider.tf
# Configure the AWS provider. Uses the aws_region variable for flexibility.
# Ensure AWS credentials are provided via environment variables, Terraform Cloud variables, or a profile.

provider "aws" {
  region = var.aws_region
  # For local testing, i can export AWS_PROFILE or AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY.
  # In Terraform Cloud, I set these as environment variables in the workspace.
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token

  # Optional: ignore self-signed certs if needed (not recommended for production)
  # insecure = true
}
