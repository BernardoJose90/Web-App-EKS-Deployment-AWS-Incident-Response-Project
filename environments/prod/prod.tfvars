tags = {
  Owner       = "Bernardo"
  Environment = "prod"
  Project     = "TerraformProject"
}

vpc_name = "prod"

# London-specific values
vpc_cidr_london        = "10.20.0.0/16"
public_subnets_london  = ["10.20.10.0/24", "10.20.20.0/24"]
private_subnets_london = ["10.20.30.0/24", "10.20.40.0/24"]

# subnets for EKS public load balancers (ALB/NLB) 
eks_public_subnets_london = ["10.20.50.0/24", "10.20.60.0/24"]

# subnets for EKS pworker nodes 
eks_private_subnets_london = ["10.20.70.0/24", "10.20.80.0/24"]
azs_london                 = ["eu-west-2a", "eu-west-2b"]

s3_my-ci-cd-artifacts = "my-ci-cd-artifacts"
github_org            = "BernardoJose90"
github_repo           = "Web-App-EKS-Deployment-AWS-Incident-Response-Project"
github_branch         = "main"
# KMS key ID for encrypting S3 objects. This will be fetched from the KMS module output.


