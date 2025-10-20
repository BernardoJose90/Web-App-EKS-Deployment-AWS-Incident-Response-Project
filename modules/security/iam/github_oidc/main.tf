terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "aws_caller_identity" "current" {}

# 1️⃣ OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 2️⃣ GitHub Actions IAM Role
resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }
}

# 3️⃣ Attach modular policies

module "s3_policy" {
  source = "./policies/s3"
  role   = aws_iam_role.github_actions_role.name
}

module "eks_policy" {
  source = "./policies/eks"
  role   = aws_iam_role.github_actions_role.name
}

module "misc_policy" {
  source = "./policies/misc"
  role   = aws_iam_role.github_actions_role.name
}

# 4️⃣ Output Role Name
output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = aws_iam_role.github_actions_role.name
}

resource "aws_iam_policy" "misc_policy" {
  name        = "GitHubActionsMiscPolicy"
  description = "Miscellaneous permissions for GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["kms:Encrypt","kms:Decrypt"]
        Resource = "*"
      }
    ]
  })
}
