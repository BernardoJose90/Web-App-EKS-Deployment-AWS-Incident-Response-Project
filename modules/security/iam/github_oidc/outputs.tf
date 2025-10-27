output "role_arn" {
  value       = aws_iam_role.terraform_execution_role.arn
  description = "ARN of the Terraform Execution Role"
}

output "role_name" {
  value       = aws_iam_role.terraform_execution_role.name
  description = "Name of the Terraform Execution Role"
}
