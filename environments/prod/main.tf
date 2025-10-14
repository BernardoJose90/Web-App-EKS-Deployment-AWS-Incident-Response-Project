terraform {
  backend "s3" {}
}


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
}

output "vpc_id" {
  value       = module.vpc_london.vpc_id
  description = "VPC ID for the London environment"
}

output "public_subnets" {
  value       = module.vpc_london.public_subnets
  description = "Public subnet IDs"
}

