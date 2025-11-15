# variables.tf
# Centralized variables so you can change behaviour per environment easily.

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1" # Frankfurt region
}

variable "cluster_name" {
  description = "Name for my EKS cluster"
  type        = string
  default     = "opsfolio-eks" #  Renamed to match Opsfolio project naming convention
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.29" #  Using a modern supported version (change as AWS supports newer)
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS nodes"
  type        = list(string)
  # Using a smaller instance types for demo / portfolio to reduce cost
  default = ["t3.small"]
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1 # Single node for demo/cost control
}

variable "max_capacity" {
  description = "Max number of worker nodes"
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Min number of worker nodes"
  type        = number
  default     = 1
}

variable "aws_auth_users" {
  description = "IAM users mapped to Kubernetes RBAC"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  sensitive = true   # <<< Hide from CLI and logs

  default = []        # <<< No ARN committed to Git
}


variable "resource_tags" {
  description = "Tags to apply to resources for billing/identification"
  type        = map(string)
  default = {
    Project     = "Opsfolio"
    Environment = "dev"
    Owner       = "Akingbade Omosebi"
    Terraform   = "true"
  }
}

