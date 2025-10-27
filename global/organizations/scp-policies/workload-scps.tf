# Environment-specific Service Control Policies

# SCP: Development environment - More permissive
resource "aws_organizations_policy" "dev_permissions" {
  name        = "DevelopmentPermissions"
  description = "Development environment permissions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowDevelopmentServices"
        Effect = "Allow"
        Action = [
          "ec2:*",
          "eks:*",
          "s3:*",
          "rds:*",
          "lambda:*",
          "iam:PassRole",
          "iam:CreateRole",
          "iam:AttachRolePolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

# SCP: Production environment - Restrictive
resource "aws_organizations_policy" "prod_restrictions" {
  name        = "ProductionRestrictions"
  description = "Production environment restrictions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyDirectInternetAccess"
        Effect = "Deny"
        Action = [
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway"
        ]
        Resource = "*"
      },
      {
        Sid    = "RequireEncryption"
        Effect = "Deny"
        Action = [
          "s3:PutObject"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      }
    ]
  })
}

# Attach policies to respective OUs
resource "aws_organizations_policy_attachment" "dev_permissions" {
  policy_id = aws_organizations_policy.dev_permissions.id
  target_id = aws_organizations_organizational_unit.dev.id
}

resource "aws_organizations_policy_attachment" "prod_restrictions" {
  policy_id = aws_organizations_policy.prod_restrictions.id
  target_id = aws_organizations_organizational_unit.prod.id
}