terraform {
  backend "s3" {}
}

# Get the current AWS caller identity for IAM context..
data "aws_caller_identity" "current" {}

# 1. Deploy London VPC with public/private subnets and EKS-specific subnets....
module "vpc_london" {
  source    = "../../../modules/network"
  providers = { aws = aws.ireland }

  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr_london
  public_subnets      = var.public_subnets_london
  private_subnets     = var.private_subnets_london
  eks_public_subnets  = var.eks_public_subnets_london
  eks_private_subnets = var.eks_private_subnets_london
  azs                 = var.azs_london
  tags                = var.tags
  region              = var.region  
  cluster_name        = var.cluster_name  # Add this for Kubernetes subnet tagging...
}

# 2. KMS Key for encrypting S3 bucket and GitHub OIDC role....
module "kms" {
  source         = "../../../modules/security/kms"
  providers      = { aws = aws.ireland }
  key_name       = var.key_name
  tags           = var.tags
  aws_account_id = data.aws_caller_identity.current.account_id
}

# 3. S3 Bucket for CI/CD artifacts..
module "s3_bucket" {
  source      = "../../../modules/storage/s3"
  providers   = { aws = aws.ireland }
  bucket_name = var.s3_my-ci-cd-artifacts
}

module "eks_iam" {
  source = "../../../modules/security/iam/eks"
  cluster_name   = var.cluster_name
  tags           = var.tags
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.region
}

# 4. GitHub OIDC Role for CI/CD.
module "github_oidc_role" {
  source         = "../../../modules/security/iam/github_oidc"
  providers      = { aws = aws.ireland}
  aws_account_id = data.aws_caller_identity.current.account_id
  github_org     = var.github_org
  github_branch  = var.github_branch
  github_repo    = var.github_repo
  kms_key_id     = module.kms.kms_key_id
  role           = "GitHubActionsRole"   # <--- Add this
}

# 5. EKS Cluster in London
module "eks_cluster" {
  source = "../../../modules/compute/eks"

  # Required variables from your existing variables.tf
  cluster_name    = var.cluster_name
  cluster_role_arn = module.eks_iam.cluster_role_arn
  node_group_role_arn = module.eks_iam.node_group_role_arn
  kubernetes_version = var.kubernetes_version
  
  # Use actual subnet IDs from VPC module instead of CIDR blocks
  subnet_ids      = module.vpc_london.eks_private_subnet_ids  # ← FIX THIS LINE
  
  # Optional variables with defaults
  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access
  public_access_cidrs     = var.public_access_cidrs
  service_ipv4_cidr       = var.service_ipv4_cidr
  enabled_cluster_log_types = var.enabled_cluster_log_types
  
  # Node group configuration
  capacity_type  = var.capacity_type
  instance_types = var.instance_types
  desired_size   = 1
  max_size       = 1
  min_size       = 1
  
  tags = var.tags
  
  depends_on = [
    module.vpc_london  # ← ADD THIS DEPENDENCY
  ]
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

output "eks_public_subnet_ids" {
  description = "EKS public subnet IDs"
  value       = module.vpc_london.eks_public_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc_london.public_subnet_ids
}