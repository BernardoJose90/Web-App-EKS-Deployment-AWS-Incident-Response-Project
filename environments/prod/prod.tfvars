# VPC Configuration
vpc_name = "prod-vpc"
vpc_cidr_london = "10.20.0.0/16"  # ← ADD THIS
azs_london = ["eu-west-2a", "eu-west-2b"]

# Subnet Configuration - ADD THESE 4 LINES
public_subnets_london  = ["10.20.10.0/24", "10.20.20.0/24"]
private_subnets_london = ["10.20.30.0/24", "10.20.40.0/24"]
eks_public_subnets_london = ["10.20.50.0/24", "10.20.60.0/24"]
eks_private_subnets_london = ["10.20.70.0/24", "10.20.80.0/24"]

# Dummy values for module outputs - ADD THESE 2 LINES
cluster_role_arn = "dummy-arn"
subnet_ids = ["dummy-id"]

# EKS Cluster Configuration.
cluster_name = "prod-eks-cluster" 
kubernetes_version = "1.29"

# Network settings
endpoint_public_access = true
endpoint_private_access = true
public_access_cidrs = ["0.0.0.0/0"]
service_ipv4_cidr = "10.100.0.0/16"

# Logging
enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

# Other settings
s3_my-ci-cd-artifacts = "my-ci-cd-artifacts"
github_org = "BernardoJose90"
github_repo = "Web-App-EKS-Deployment-AWS-Incident-Response-Project"
github_branch = "main"
key_name = "KMS_key_for_CI/CD_artifacts"

# Tags
tags = {
  Owner       = "Bernardo"
  Environment = "prod"
  Project     = "TerraformProject"
}