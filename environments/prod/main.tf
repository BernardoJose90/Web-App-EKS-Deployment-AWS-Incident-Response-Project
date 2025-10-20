terraform {
  backend "s3" {}
}

# Get the current AWS caller identity for IAM context
data "aws_caller_identity" "current" {}

# Deploy London VPC with public/private subnets and EKS-specific subnets.
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
  region              = var.region_london # London region
  cluster_name        = var.cluster_name  # Add this for Kubernetes subnet tagging.
}

# KMS Key for encrypting S3 bucket and GitHub OIDC role
module "kms" {
  source         = "../../modules/security/kms"
  providers      = { aws = aws.london }
  key_name       = var.key_name
  tags           = var.tags
  aws_account_id = data.aws_caller_identity.current.account_id
}

# S3 Bucket for CI/CD artifacts
module "s3_bucket" {
  source      = "../../modules/storage/s3"
  providers   = { aws = aws.london }
  bucket_name = var.s3_my-ci-cd-artifacts
}

# GitHub OIDC Role for CI/CD
module "github_oidc_role" {
  source         = "../../modules/security/iam/github_oidc"
  providers      = { aws = aws.london }
  aws_account_id = data.aws_caller_identity.current.account_id
  github_org     = var.github_org
  github_branch  = var.github_branch
  github_repo    = var.github_repo
  kms_key_id     = module.kms.kms_key_id
}

# IAM roles for EKS - ADD THIS MISSING MODULE
module "eks_iam" {
  source         = "../../modules/security/iam/eks"
  cluster_name   = var.cluster_name
  environment    = "prod"
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.region_london
}


# EKS Cluster in London
module "eks_cluster" {
  source       = "../../modules/compute/eks"
  cluster_name        = var.cluster_name
  cluster_role_arn    = module.eks_iam.cluster_role_arn
  kubernetes_version  = var.kubernetes_version
  
  # Use EKS-specific private subnets for worker nodes - FIXED: using correct module name
  subnet_ids              = module.vpc_london.eks_private_subnet_ids
  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access
  public_access_cidrs     = var.public_access_cidrs
  service_ipv4_cidr       = var.service_ipv4_cidr
  enabled_cluster_log_types = var.enabled_cluster_log_types
  
  node_groups = {
    # Production node group with appropriate sizing
    prod-workers = {
      node_role_arn      = module.eks_iam.node_group_role_arn
      subnet_ids         = module.vpc_london.eks_private_subnet_ids  # FIXED: using correct module name
      capacity_type      = "ON_DEMAND"
      instance_types     = ["t3.micro"]  # Larger instances for production
      desired_size       = 1
      max_size           = 2
      min_size           = 1
      update_max_unavailable = 1
    }
  }

  tags = {
    Environment = "prod"
    Project     = "my-eks-project"
    Terraform   = "true"
  }
}

# Outputs for your cluster
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_cluster.cluster_id
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks_cluster.cluster_security_group_id
}

# Network outputs for reference - FIXED: using correct module name.
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc_london.vpc_id
}

/*
output "eks_private_subnet_ids" {
  description = "EKS private subnet IDs"
  value       = module.vpc_london.eks_private_subnet_ids
}
*/
output "eks_public_subnet_ids" {
  description = "EKS public subnet IDs"
  value       = module.vpc_london.eks_public_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc_london.public_subnet_ids
}