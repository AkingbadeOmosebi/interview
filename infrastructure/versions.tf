# versions.tf

terraform {
  required_version = ">= 1.4.0"

  # Terraform Cloud backend for remote state management
  backend "remote" {
    organization = "opsfolio" # My TF Cloud organization name

    workspaces {
      name = "opsfolio-eks-dev" # Myy TF Cloud workspace name
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40, < 7.0"
    }
  }
}