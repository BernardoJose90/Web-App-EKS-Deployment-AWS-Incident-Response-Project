variable "role" {
  type        = string
  description = "IAM role name to attach the policy to"
}

resource "aws_iam_policy" "s3_policy" {
  name        = "GitHubActionsS3Policy"
  description = "S3 permissions for GitHub Actions Terraform backend"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketPolicy",
          "s3:GetBucketLocation",
          "s3:GetBucketAcl",
          "s3:GetBucketCORS",
          "s3:GetBucketWebsite",
          "s3:GetBucketVersioning",
          "s3:GetAccelerateConfiguration",
          "s3:GetBucketRequestPayment"
        ],
        Resource = [
          "arn:aws:s3:::cloudsec-project-tfstate"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::cloudsec-project-tfstate/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutBucketVersioning",
          "s3:PutBucketEncryption",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketPolicy"
        ],
        Resource = [
          "arn:aws:s3:::cloudsec-project-tfstate"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = var.role
  policy_arn = aws_iam_policy.s3_policy.arn
}
