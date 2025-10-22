output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.cluster.arn
}

output "node_group_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = aws_iam_role.node_group.arn
}

output "cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = aws_iam_role.cluster.name
}

output "node_group_role_name" {
  description = "Name of the EKS node group IAM role"
  value       = aws_iam_role.node_group.name
}

output "node_group_instance_profile_name" {
  description = "Name of the IAM instance profile for EKS worker nodes"
  value       = aws_iam_instance_profile.node_group.name
}