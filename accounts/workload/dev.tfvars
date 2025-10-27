
region = "eu-west-1"
environment = "Dev"

# VPC Configuration
vpc_name = "dev-vpc"
vpc_cidr_ireland = "10.0.0.0/16"  # ← ADD THIS
azs_ireland = ["eu-west-1a", "eu-west-1b"]


# Subnet Configuration - ADD THESE 4 LINES
public_subnets_ireland  = ["10.0.10.0/24", "10.0.20.0/24"]
private_subnets_ireland = ["10.0.30.0/24", "10.0.40.0/24"]
eks_public_subnets_ireland = ["10.0.50.0/24", "10.0.60.0/24"]
eks_private_subnets_ireland = ["10.0.70.0/24", "10.0.80.0/24"]

# Dummy values for module outputs - ADD THESE 2 LINES
cluster_role_arn = "dummy-arn"
subnet_ids = ["dummy-id"]

# EKS Cluster Configuration.
cluster_name = "dev-eks-cluster" 
instance_types = [ "t2.micro" ]
capacity_type="SPOT"
kubernetes_version = "1.29"

  
# Network settings
endpoint_public_access = true
endpoint_private_access = true
public_access_cidrs = ["0.0.0.0/0"]
service_ipv4_cidr = "10.100.0.0/16"

# Logging
enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

# Tags
tags = {
  Owner       = "Bernardo"
  Environment = var.environment
  Project     = "TerraformProject"
}
