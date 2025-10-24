

# VPC Configuration
vpc_name = "prod-vpc"
vpc_cidr_london = "10.20.0.0/16"  # ← ADD THIS
azs_london = ["eu-west-2a", "eu-west-2b"]
azs_ireland = ["eu-west-1a", "eu-west-1b"]


# Subnet Configuration - ADD THESE 4 LINES
public_subnets_london  = ["10.20.10.0/24", "10.20.20.0/24"]
private_subnets_london = ["10.20.30.0/24", "10.20.40.0/24"]
eks_public_subnets_london = ["10.20.50.0/24", "10.20.60.0/24"]
eks_private_subnets_london = ["10.20.70.0/24", "10.20.80.0/24"]

  
# Network settings
endpoint_public_access = true
endpoint_private_access = true
public_access_cidrs = ["0.0.0.0/0"]
service_ipv4_cidr = "10.100.0.0/16"

# Tags
tags = {
  Owner       = "Bernardo"
  Environment = "prod"
  Project     = "TerraformProject"
}
