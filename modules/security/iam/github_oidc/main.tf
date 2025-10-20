terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Get current AWS account
data "aws_caller_identity" "current" {}

# 1️⃣ OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
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
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
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

# 3️⃣ Full GitHub Actions Policy
resource "aws_iam_policy" "github_actions_full_policy" {
  name        = "GitHubActionsFullPolicy"
  description = "Full permissions for GitHub Actions Terraform CI/CD"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Terraform backend S3 bucket
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::cloudsec-project-tfstate",
          "arn:aws:s3:::cloudsec-project-tfstate/*"
        ]
      },

      # CI/CD artifacts S3 bucket
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::my-ci-cd-artifacts-*",
          "arn:aws:s3:::my-ci-cd-artifacts-*/*"
        ]
      },

      # EC2 / VPC / Networking read access
      {
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
      },

      # KMS for CI/CD
      {
        Effect = "Allow"
        Action = [
          "kms:*"
        ]
        Resource = "*"
      },

      # EKS permissions
      {
        Effect = "Allow"
        Action = [
          "eks:*"
        ]
        Resource = "*"
      },

      # Secrets Manager access
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:*"
        ]
        Resource = [
          "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:prod/kms-key-*"
        ]
      },

      # IAM / OIDC read access
      {
        Effect = "Allow"
        Action = [
          "iam:*"
        ]
        Resource = "*"
      },

      # Optional CloudWatch logs for monitoring
      {
        Effect = "Allow"
        Action = [
          "logs:*"

        ]
        Resource = "*"
      }
    ]
  })
}

# 4️⃣ Attach the full policy to the GitHub Actions Role
resource "aws_iam_role_policy_attachment" "attach_github_actions_full_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_full_policy.arn
}

# 5️⃣ Output Role Name
output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = aws_iam_role.github_actions_role.name
}
