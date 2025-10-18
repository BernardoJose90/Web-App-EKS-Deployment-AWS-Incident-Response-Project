variable "tags" {
  description = "Global tags for all resources"
  type        = map(string)
  default = {
    Owner       = "Bernardo Jose"
    Environment = "dev"
    Project     = "TerraformProject"
  }
}

