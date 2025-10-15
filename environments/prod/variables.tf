# environments/prod/variables.tf
variable "vpc_name" {
  type = string
}

variable "tags" {
  description = "Global tags for all resources"
  type        = map(string)
  default = {
    Owner       = "Bernardo"
    Environment = "prod"
    Project     = "TerraformProject"
  }
}


# London variables
variable "vpc_cidr_london" { type = string }
variable "public_subnets_london" { type = list(string) }
variable "private_subnets_london" { type = list(string) }

variable "eks_public_subnets_london" { type = list(string) }
variable "eks_private_subnets_london" { type = list(string) }
variable "azs_london" { type = list(string) }

variable "bucket_name" {
  description = "The name of the S3 bucket for CI/CD artifacts"
  type        = string
  default     = "my-ci-cd-artifacts"
}