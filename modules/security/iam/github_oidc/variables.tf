variable "role_name" {
  type        = string
  description = "Name of the Terraform execution role"
}

variable "github_repo" {
  
  type        = string
  description = "GitHub repository in format owner/repo"
}

variable "github_branch" {

  type        = string
  description = "GitHub branch to allow access"
  default     = "main"
}

variable "policy_arn" {
  type        = string
  description = "AWS managed policy ARN to attach to the role"
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}
