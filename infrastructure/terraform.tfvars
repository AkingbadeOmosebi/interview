# terraform.tfvars
# Variable values for your EKS cluster deployment

aws_region      = "eu-central-1"
cluster_name    = "opsfolio-eks"
cluster_version = "1.29"

# Node configuration
node_instance_types = ["t3.small"]
desired_capacity    = 1
max_capacity        = 1
min_capacity        = 1

# RBAC Configuration - IAM Users with EKS Access
# Replace these ARNs with your actual IAM user ARNs from AWS Console
aws_auth_users = [
  {
    userarn  = "arn:aws:iam::194722436853:user/Ak_DevOps"
    username = "Ak_DevOps"
    groups   = ["system:masters"]
  }
]

# Resource tags
resource_tags = {
  Project     = "Opsfolio"
  Environment = "dev"
  Owner       = "Akingbade Omosebi"
  Terraform   = "true"
  Purpose     = "Portfolio-Demo"
}