terraform {
  backend "s3" {}
}

# DynamoDB table via module
module "terraform_backend" {
  source     = "../../modules/terraform_backend"
  table_name = "terraform-state-locks"
  tags = {
    Name = "Terraform State Lock Table"
  }
}

# TerraformExecutionRole for GitHub OIDC
module "terraform_execution_role" {
  source        = "../../modules/security/iam/github_oidc"
  role_name     = var.role_name
  github_repo   = var.github_repo
  github_branch = var.github_branch
}
