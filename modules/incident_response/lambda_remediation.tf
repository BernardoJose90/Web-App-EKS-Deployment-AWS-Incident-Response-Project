# Lambda Functions for Automated Incident Response

# Lambda function for compromised IAM key response
resource "aws_lambda_function" "revoke_compromised_key" {
  filename         = "security_automation.zip"
  function_name    = "revoke-compromised-key"
  role            = aws_iam_role.lambda_remediation_role.arn
  handler         = "security_automation.revoke_compromised_key"
  runtime         = "python3.9"
  timeout         = 300

  environment {
    variables = {
      SECURITY_HUB_ARN = var.security_hub_arn
      SNS_TOPIC_ARN    = aws_sns_topic.security_alerts.arn
    }
  }

  tags = var.tags
}

# Lambda function for public S3 bucket response
resource "aws_lambda_function" "secure_public_bucket" {
  filename         = "security_automation.zip"
  function_name    = "secure-public-bucket"
  role            = aws_iam_role.lambda_remediation_role.arn
  handler         = "security_automation.secure_public_bucket"
  runtime         = "python3.9"
  timeout         = 300

  environment {
    variables = {
      SECURITY_HUB_ARN = var.security_hub_arn
      SNS_TOPIC_ARN    = aws_sns_topic.security_alerts.arn
    }
  }

  tags = var.tags
}

# Lambda function for EC2 instance isolation
resource "aws_lambda_function" "isolate_compromised_instance" {
  filename         = "security_automation.zip"
  function_name    = "isolate-compromised-instance"
  role            = aws_iam_role.lambda_remediation_role.arn
  handler         = "security_automation.isolate_compromised_instance"
  runtime         = "python3.9"
  timeout         = 300

  environment {
    variables = {
      SECURITY_HUB_ARN = var.security_hub_arn
      SNS_TOPIC_ARN    = aws_sns_topic.security_alerts.arn
    }
  }

  tags = var.tags
}

# IAM role for Lambda remediation functions
resource "aws_iam_role" "lambda_remediation_role" {
  name = "lambda-remediation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Lambda remediation
resource "aws_iam_role_policy" "lambda_remediation_policy" {
  name = "lambda-remediation-policy"
  role = aws_iam_role.lambda_remediation_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:UpdateAccessKey",
          "iam:DeleteAccessKey",
          "iam:ListAccessKeys",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketAcl",
          "s3:GetBucketAcl",
          "s3:GetBucketPublicAccessBlock"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifySecurityGroupRules",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "securityhub:BatchUpdateFindings",
          "securityhub:GetFindings"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.security_alerts.arn
      }
    ]
  })
}

# Attach basic execution role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_remediation_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# SNS topic for security alerts
resource "aws_sns_topic" "security_alerts" {
  name = "security-incident-alerts"

  tags = var.tags
}

# EventBridge rules for automated response
resource "aws_cloudwatch_event_rule" "compromised_key_rule" {
  name        = "compromised-key-detection"
  description = "Trigger remediation for compromised IAM keys"

  event_pattern = jsonencode({
    source      = ["aws.securityhub"]
    detail-type = ["Security Hub Findings - Imported"]
    detail = {
      findings = {
        product_name = ["Security Hub"]
        types = ["Software and Configuration Checks/IAM/Privilege Escalation"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "compromised_key_target" {
  rule      = aws_cloudwatch_event_rule.compromised_key_rule.name
  target_id = "RevokeCompromisedKey"
  arn       = aws_lambda_function.revoke_compromised_key.arn
}

resource "aws_lambda_permission" "allow_eventbridge_compromised_key" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.revoke_compromised_key.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.compromised_key_rule.arn
}

# Public S3 bucket detection rule
resource "aws_cloudwatch_event_rule" "public_bucket_rule" {
  name        = "public-bucket-detection"
  description = "Trigger remediation for public S3 buckets"

  event_pattern = jsonencode({
    source      = ["aws.securityhub"]
    detail-type = ["Security Hub Findings - Imported"]
    detail = {
      findings = {
        product_name = ["Security Hub"]
        types = ["Software and Configuration Checks/S3/Bucket Public Access"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "public_bucket_target" {
  rule      = aws_cloudwatch_event_rule.public_bucket_rule.name
  target_id = "SecurePublicBucket"
  arn       = aws_lambda_function.secure_public_bucket.arn
}

resource "aws_lambda_permission" "allow_eventbridge_public_bucket" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.secure_public_bucket.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.public_bucket_rule.arn
}
