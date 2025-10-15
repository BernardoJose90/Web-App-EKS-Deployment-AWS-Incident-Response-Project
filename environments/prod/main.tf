terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}


# Deploy London VPC with public/private subnets and EKS-specific subnets
module "vpc_london" {
  source    = "../../modules/network"
  providers = { aws = aws.london }

  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr_london
  public_subnets      = var.public_subnets_london
  private_subnets     = var.private_subnets_london
  eks_public_subnets  = var.eks_public_subnets_london
  eks_private_subnets = var.eks_private_subnets_london
  azs                 = var.azs_london
  tags                = var.tags
  region              = "eu-west-2"
}

module "kms" {
  source    = "../../modules/security/kms"
  providers = { aws = aws.london }
}

module "s3_bucket" {
  source      = "../../modules/storage/s3"
  providers   = { aws = aws.london }
  bucket_name = var.s3_my-ci-cd-artifacts
}

module "github_oidc_role" {
  source         = "../../modules/security/iam/github_oidc"
  providers   = { aws = aws.london }
  aws_account_id = data.aws_caller_identity.current.account_id
  github_org     = var.github_org
  github_branch  = var.github_branch
  github_repo    = var.github_repo
  kms_key_id     = module.kms.kms_key_id
}


output "vpc_id" {
  value       = module.vpc_london.vpc_id
  description = "VPC ID for the London environment"
}

output "public_subnets" {
  value       = module.vpc_london.public_subnets
  description = "Public subnet IDs"
}

output "eks_private_subnets" {
  value       = module.vpc_london.eks_private_subnets
  description = "EKS Private subnet IDs"

}

output "eks_public_subnets" {
  value       = module.vpc_london.eks_public_subnets
  description = "EKS Public subnet IDs"

}

