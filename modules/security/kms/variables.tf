variable "aws_account_id" {
  description = "The AWS Account ID where the KMS key will be created."
  type        = string
  
}

variable "key_name" {
  description = "The alias name for the KMS key."
  type        = string  
}

variable "tags" {
  description = "A map of tags to assign to the KMS key"
  type        = map(string)
  default     = {}
}   