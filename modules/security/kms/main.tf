terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16"
    }
  }
}

data "aws_caller_identity" "current" {}


resource "aws_kms_key" "ci_cd" {
  description             = "KMS key for CI/CD artifacts"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-${var.key_name}-${data.aws_caller_identity.current.account_id}"
    }
  )
    lifecycle {
    prevent_destroy = true   # prevents accidental 'terraform destroy'

  }
}

resource "aws_kms_alias" "ci_cd_alias" {
  name          = "alias/${var.key_name}"  
  target_key_id = aws_kms_key.ci_cd.id
}

output "kms_key_id" {
  value = aws_kms_key.ci_cd.key_id
}

