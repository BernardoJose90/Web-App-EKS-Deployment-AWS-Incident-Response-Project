variable "table_name" {
  type        = string
  description = "Name of the DynamoDB table for Terraform state locking"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the DynamoDB table"
  default     = {}
}
