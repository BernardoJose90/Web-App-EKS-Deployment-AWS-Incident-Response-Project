terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16"
    }
  }
}

data "aws_caller_identity" "current" {}


# Create the S3 bucket
resource "aws_s3_bucket" "artifacts" {
  bucket = "my-ci-cd-artifacts-${data.aws_caller_identity.current.account_id}-eu-west-2" # Example: my-ci-cd-artifacts-123456789012-eu-west-2}"


  # Prevent accidental deletion in prod
  force_destroy = false

  tags = {
    Name        = var.bucket_name
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
  lifecycle {
    prevent_destroy = true # prevents accidental 'terraform destroy'
    ignore_changes  = [tags] # ignore tag drift, useful when tags are managed elsewhere
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Default encryption (SSE-KMS recommended)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.artifacts.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create a "prod/" folder placeholder object
resource "aws_s3_object" "prod_folder" {
  bucket = aws_s3_bucket.artifacts.bucket
  key    = "prod/" # S3 folders are just prefixes ending with '/'
  acl    = "private"
}

