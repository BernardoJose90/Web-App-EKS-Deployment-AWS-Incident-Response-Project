# Service Control Policies - Security Guardrails

# SCP: Prevent leaving the organization
resource "aws_organizations_policy" "prevent_leaving_org" {
  name        = "PreventLeavingOrganization"
  description = "Prevents member accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PreventLeavingOrganization"
        Effect = "Deny"
        Action = [
          "organizations:LeaveOrganization"
        ]
        Resource = "*"
      }
    ]
  })
}

# SCP: Prevent root user usage
resource "aws_organizations_policy" "prevent_root_usage" {
  name        = "PreventRootUsage"
  description = "Prevents root user from performing actions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PreventRootUsage"
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalType" = "Root"
          }
        }
      }
    ]
  })
}

# SCP: Prevent public S3 buckets
resource "aws_organizations_policy" "prevent_public_s3" {
  name        = "PreventPublicS3Buckets"
  description = "Prevents creation of public S3 buckets"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PreventPublicS3Buckets"
        Effect = "Deny"
        Action = [
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketAcl",
          "s3:PutObjectAcl"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-acl" = "private"
          }
        }
      }
    ]
  })
}

# SCP: Require MFA for sensitive operations
resource "aws_organizations_policy" "require_mfa" {
  name        = "RequireMFA"
  description = "Requires MFA for sensitive operations"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RequireMFA"
        Effect = "Deny"
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

# Attach guardrail policies to all OUs
resource "aws_organizations_policy_attachment" "prevent_leaving_org_all" {
  policy_id = aws_organizations_policy.prevent_leaving_org.id
  target_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_policy_attachment" "prevent_root_usage_all" {
  policy_id = aws_organizations_policy.prevent_root_usage.id
  target_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_policy_attachment" "prevent_public_s3_all" {
  policy_id = aws_organizations_policy.prevent_public_s3.id
  target_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_policy_attachment" "require_mfa_all" {
  policy_id = aws_organizations_policy.require_mfa.id
  target_id = aws_organizations_organization.main.roots[0].id
}