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

variable "s3_my-ci-cd-artifacts" {
  type = string
}


variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type = string
}
