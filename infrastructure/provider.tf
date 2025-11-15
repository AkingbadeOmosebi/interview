# provider.tf
# Configure the AWS provider. Uses the aws_region variable for flexibility.
# Ensure AWS credentials are provided via environment variables, Terraform Cloud variables, or a profile.

provider "aws" {
  region = var.aws_region
  # >>> TIP: For local testing, export AWS_PROFILE or AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY.
  # >>> In Terraform Cloud, set these as environment variables in the workspace.
}

