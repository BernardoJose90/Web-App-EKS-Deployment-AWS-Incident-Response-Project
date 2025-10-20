

variable "aws_account_id" {
  description = "AWS account ID where the role will be created"
  type        = string
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the role"
  type        = string
  default     = "main"
}

variable "kms_key_id" {
  description = "KMS Key ID for S3 encryption"
  type        = string
}

variable "role" {
  type        = string
  description = "IAM role name to attach the policy to"
}
