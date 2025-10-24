# Transit Gateway, DNS, 
terraform {
  backend "s3" {}
}

# Get the current AWS caller identity for IAM context..
data "aws_caller_identity" "current" {}

# 1. Deploy London VPC with public/private subnets and EKS-specific subnets....
module "vpc_london" {
  source    = "../../../modules/network"
  providers = { aws = aws.london }# this is used to specify region to deploy this module

  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr_london
  public_subnets      = var.public_subnets_london
  private_subnets     = var.private_subnets_london
  eks_public_subnets  = var.eks_public_subnets_london
  eks_private_subnets = var.eks_private_subnets_london
  azs                 = var.azs_london
  tags                = var.tags
  region              = var.region  # this region veriable is used for tagging purpose
  cluster_name        = var.cluster_name  # Add this for Kubernetes subnet tagging...
}