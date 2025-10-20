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
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation"
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
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutBucketPolicy",
          "s3:PutBucketVersioning",
          "s3:PutBucketEncryption",
          "s3:PutBucketPublicAccessBlock"
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
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeAddresses",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeKeyPairs"
        ]
        Resource = "*"
      },

      # KMS for CI/CD
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },

      # EKS permissions
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:CreateNodegroup",
          "eks:DeleteNodegroup",
          "eks:UpdateClusterConfig",
          "eks:UpdateNodegroupConfig"
        ]
        Resource = "*"
      },
      # 7️⃣ Secrets Manager access
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:prod/kms-key-*"
        ]
      },

      # Optional CloudWatch logs for monitoring
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
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
