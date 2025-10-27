# AWS Organizations - Root Account Management
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Get current AWS account
data "aws_caller_identity" "current" {}

# AWS Organizations (assuming it's already enabled)
# Note: You need to enable Organizations manually first in the AWS Console
data "aws_organizations_organization" "main" {}

# Create member accounts
resource "aws_organizations_account" "security" {
  name  = "Security Account"
  email = var.security_account_email
  role_name = "OrganizationAccountAccessRole"
  
  depends_on = [data.aws_organizations_organization.main]
}

resource "aws_organizations_account" "network" {
  name  = "Network Account"
  email = var.network_account_email
  role_name = "OrganizationAccountAccessRole"
  
  depends_on = [data.aws_organizations_organization.main]
}

resource "aws_organizations_account" "production" {
  name  = "Production Account"
  email = var.production_account_email
  role_name = "OrganizationAccountAccessRole"
  
  depends_on = [data.aws_organizations_organization.main]
}

resource "aws_organizations_account" "development" {
  name  = "Development Account"
  email = var.development_account_email
  role_name = "OrganizationAccountAccessRole"
  
  depends_on = [data.aws_organizations_organization.main]
}

resource "aws_organizations_account" "staging" {
  name  = "Staging Account"
  email = var.staging_account_email
  role_name = "OrganizationAccountAccessRole"
  
  depends_on = [data.aws_organizations_organization.main]
}

# Organizational Units
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.main.roots[0].id

  depends_on = [aws_organizations_organization.main]
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = aws_organizations_organization.main.roots[0].id

  depends_on = [aws_organizations_organization.main]
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = aws_organizations_organization.main.roots[0].id

  depends_on = [aws_organizations_organization.main]
}

# Workload OU Sub-OUs
resource "aws_organizations_organizational_unit" "dev" {
  name      = "Development"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_organizational_unit" "staging" {
  name      = "Staging"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_organizational_unit" "prod" {
  name      = "Production"
  parent_id = aws_organizations_organizational_unit.workloads.id
}