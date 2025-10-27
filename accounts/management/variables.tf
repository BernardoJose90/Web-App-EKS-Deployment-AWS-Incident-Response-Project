
variable "region" {
  description = "AWS region to use for this environment"
  type        = string
  default     = "eu-west-2"
}


variable "azs_london" {
  description = "Availability zones for London"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "azs_ireland" {
  description = "Availability zones for ireland"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "role_name" {
  type = string
  default = "TerraformExecutionRole"
}
variable "github_repo" {
  type = string
  default = "BernardoJose90/Web-App-EKS-Deployment-AWS-Incident-Response-Project"
}
variable "github_branch" {
  type = string
  default = "main"
}