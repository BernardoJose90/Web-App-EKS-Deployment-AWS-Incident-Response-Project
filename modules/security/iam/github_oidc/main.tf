terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
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

      # ========== SECURITY GROUP MANAGEMENT ==========
      {
        Sid = "SecurityGroupManagement"
        Effect = "Allow"
        Action = [
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeSecurityGroups"
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
          "eks:UpdateNodegroupConfig",
          "eks:TagResource",
          "eks:UntagResource"
        ]
        Resource = "*"
      },

      # ========== EKS ADDON MANAGEMENT ==========
      {
        Sid = "EKSAddonManagement"
        Effect = "Allow"
        Action = [
          "eks:CreateAddon",
          "eks:DescribeAddon",
          "eks:DeleteAddon",
          "eks:ListAddons",
          "eks:UpdateAddon"
        ]
        Resource = "*"
      },

      # ========== EKS IAM ROLE MANAGEMENT ==========
      {
        Sid = "EKSRoleManagement",
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole",
          "iam:GetServiceLinkedRoleDeletionStatus"
        ]
        Resource = "arn:aws:iam::*:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS*"
      },

      # ========== LOAD BALANCER MANAGEMENT ==========
      {
        Sid = "LoadBalancerManagement"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroupAttributes"
        ]
        Resource = "*"
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
          "autoscaling:CreateLaunchConfiguration",
          "autoscaling:DeleteLaunchConfiguration",
          "ec2:DescribeLaunchTemplates",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:ModifyLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:DeleteLaunchTemplateVersion"
        ]
        Resource = "*"
      },

      # ========== S3 SPECIFIC ACCESS (LEAST PRIVILEGE) ==========
      {
        Sid = "S3ListBuckets"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::cloudsec-project-tfstate",
          "arn:aws:s3:::my-ci-cd-artifacts-*"
        ]
      },
      {
        Sid = "S3TerraformState"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
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
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
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
          "s3:PutBucketPolicy"
        ]
        Resource = [
          "arn:aws:s3:::my-ci-cd-artifacts-*",
          "arn:aws:s3:::cloudsec-project-tfstate"
        ]
      },

      # ========== KMS LIMITED ACCESS ==========
      {
        Sid = "KMSLimitedAccess"
        Effect = "Allow"
        Action = [
          "kms:CreateKey",
          "kms:DescribeKey",
          "kms:ScheduleKeyDeletion",
          "kms:CreateAlias",
          "kms:DeleteAlias",
          "kms:EnableKey",
          "kms:DisableKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ListAliases",
          "kms:ListKeys"
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
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/GitHubActionsRole",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/GitHubActionsPolicy*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*eks*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*nodegroup*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/prod-eks-cluster-*"
        ]
      },

      # ========== CLOUDWATCH LOGS ==========
      {
        Sid = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:DeleteLogGroup",
          "logs:PutRetentionPolicy",
          "logs:DescribeLogStreams",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/eks/*"
      },

      # ========== ECR ACCESS ==========
      {
        Sid = "ECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },

      # ========== ROUTE53 ACCESS ==========
      {
        Sid = "Route53Access"
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
          "route53:GetHostedZone",
          "route53:ListHostedZones"
        ]
        Resource = "arn:aws:route53:::hostedzone/*"
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
          "secretsmanager:PutSecretValue",
          "secretsmanager:TagResource"
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