terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16"
    }
  }
}

data "aws_caller_identity" "current" {}

# IAM Role for GitHub Actions OIDC
resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
          }
        }
      }
    ]
  })
  lifecycle {
    prevent_destroy = true   # prevents accidental 'terraform destroy'
    ignore_changes  = [tags] # ignore tag drift, useful when tags are managed elsewhere
  }
}

# Least-privilege policy for GitHub Actions
resource "aws_iam_policy" "github_actions_policy" {
  name        = "GitHubActionsPolicy"
  description = "Least privilege for Terraform + EKS CI workflow"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:AttachInternetGateway",
          "ec2:CreateInternetGateway"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:CreateCluster",
          "eks:DescribeCluster",
          "eks:DeleteCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "arn:aws:s3:::my-ci-cd-artifacts/prod/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "arn:aws:kms:eu-west-2:${data.aws_caller_identity.current.account_id}:key/${var.kms_key_id}"
      }
    ]
  })
  lifecycle {
    prevent_destroy = true   # prevents accidental 'terraform destroy'
    ignore_changes  = [tags] # ignore tag drift, useful when tags are managed elsewhere
  }
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_github_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
  lifecycle {
    prevent_destroy = true   # prevents accidental 'terraform destroy'
    ignore_changes  = [tags] # ignore tag drift, useful when tags are managed elsewhere
  }
}


