terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16"
    }
  }
}

# Create the S3 bucket
resource "aws_s3_bucket" "artifacts" {
  bucket = var.bucket_name

  # Prevent accidental deletion in prod
  force_destroy = false

  tags = {
    Name        = var.bucket_name
    Environment = "prod"
    ManagedBy   = "Terraform"
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

