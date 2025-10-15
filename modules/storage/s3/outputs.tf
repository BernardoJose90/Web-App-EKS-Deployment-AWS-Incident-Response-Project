output "bucket_name" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.artifacts.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.artifacts.arn
}

output "prod_folder_key" {
  description = "Key for the prod folder inside the bucket"
  value       = aws_s3_object.prod_folder.key
}
