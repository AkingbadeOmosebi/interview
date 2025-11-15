# versions.tf
# Lock Terraform and provider requirements so builds are reproducible.

terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Keep reasonably up-to-date but use a minor pin for stability.
      version = "~> 5.40"
    }
  }
}

