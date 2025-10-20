

variable "s3_bucket_arns" {
  type        = list(string)
  description = "List of S3 bucket ARNs for access"
  default     = []
}
