# provider.tf
# Configure the AWS provider. Uses the aws_region variable for flexibility.
# Ensure AWS credentials are provided via environment variables, Terraform Cloud variables, or a profile.

provider "aws" {
  region = var.aws_region
  # For local testing, i can export AWS_PROFILE or AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY.
  # In Terraform Cloud, I set these as environment variables in the workspace.
}

# Use module outputs instead of using data sources (avoids timing issues)
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--region", var.aws_region, "--cluster-name", module.eks.cluster_name]
  }
}

