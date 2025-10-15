terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16"
    }
  }
}

resource "aws_kms_key" "ci_cd" {
  description             = "KMS key for CI/CD artifacts"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
  lifecycle {
    prevent_destroy = true   # prevents accidental 'terraform destroy'
    ignore_changes  = [tags] # ignore tag drift, useful when tags are managed elsewhere
  }
}

output "kms_key_id" {
  value = aws_kms_key.ci_cd.key_id
}
