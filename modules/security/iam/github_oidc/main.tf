terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16"
    }
  }
}

data "aws_caller_identity" "current" {}

# 1️⃣ Create OIDC Provider for GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1", # GitHub's OIDC thumbprint
  ]
}

# 2️⃣ Create OIDC role for GitHub Actions
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
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# 3️⃣ Create least-privilege policy for GitHub Actions
resource "aws_iam_policy" "github_actions_policy" {
  name        = "GitHubActionsPolicy-Production"
  description = "Complete least privilege policy for GitHub Actions Terraform deployment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ========== EC2 & NETWORKING ==========
      {
        Sid = "EC2Networking"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      },

      # ========== EKS CLUSTER MANAGEMENT ==========
      {
        Sid = "EKSClusterManagement"
        Effect = "Allow"
        Action = [
          "eks:CreateCluster",
          "eks:DescribeCluster",
          "eks:DeleteCluster",
          "eks:ListClusters",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:CreateNodegroup",
          "eks:DeleteNodegroup",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:UpdateNodegroupConfig"
        ]
        Resource = "*"
      },

      # ========== S3 COMPLETE READ ACCESS ==========
      {
        Sid = "S3ReadAll"
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*"
        ]
        Resource = "*"
      },

      # ========== S3 WRITE ACCESS (LEAST PRIVILEGE) ==========
      {
        Sid = "S3TerraformState"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::cloudsec-project-tfstate/prod/terraform.tfstate*"
        ]
      },
      {
        Sid = "S3ArtifactsWrite"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = [
          "arn:aws:s3:::my-ci-cd-artifacts-*/*"
        ]
      },
      {
        Sid = "S3BucketConfiguration"
        Effect = "Allow"
        Action = [
          "s3:PutBucketVersioning",
          "s3:PutBucketEncryption",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketPolicy",
          "s3:PutBucketCors",
          "s3:PutBucketWebsite",
          "s3:PutAccelerateConfiguration",
          "s3:PutBucketRequestPayment",
          "s3:PutBucketLogging",
          "s3:PutBucketLifecycleConfiguration",
          "s3:PutBucketNotification",
          "s3:PutBucketReplication"
        ]
        Resource = [
          "arn:aws:s3:::my-ci-cd-artifacts-*",
          "arn:aws:s3:::cloudsec-project-tfstate"
        ]
      },

      # ========== KMS KEY MANAGEMENT ==========
      {
        Sid = "KMSFullAccess"
        Effect = "Allow"
        Action = [
          "kms:*"
        ]
        Resource = "*"
      },

      # ========== IAM OIDC & ROLE MANAGEMENT ==========
      {
        Sid = "IAMReadOnly"
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*"
        ]
        Resource = "*"
      },
      {
        Sid = "IAMWriteOperations"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/GitHubActionsRole",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/GitHubActionsPolicy*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        ]
      },

      # ========== AUTOSCALING & LAUNCH TEMPLATES ==========
      {
        Sid = "AutoScalingManagement"
        Effect = "Allow"
        Action = [
          "autoscaling:Describe*",
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup",
          "ec2:DescribeLaunchTemplates",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:ModifyLaunchTemplate"
        ]
        Resource = "*"
      },

      # ========== SECRETS MANAGER ==========
      {
        Sid = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:PutSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:prod/kms-key*"
      },

      # ========== BASIC STS PERMISSIONS ==========
      {
        Sid = "StsBasic"
        Effect = "Allow"
        Action = [
          "sts:GetCallerIdentity",
          "sts:AssumeRole"
        ]
        Resource = "*"
      }
    ]
  })
}

# 4️⃣ Attach policy to role
resource "aws_iam_role_policy_attachment" "attach_github_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}


output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = aws_iam_role.github_actions_role.name
}