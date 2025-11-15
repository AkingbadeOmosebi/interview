# outputs.tf
# Useful outputs to integrate with other tooling and to set kubeconfig.

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_id # module.eks.cluster_name or cluster_id depending on module version
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA certificate (base64)"
  value       = module.eks.cluster_certificate_authority_data
}

output "kubeconfig_cmd" {
  description = "Command to configure kubectl (run locally)"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_id}"
}

