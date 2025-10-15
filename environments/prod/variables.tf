# environments/prod/variables.tf
variable "vpc_name" {
  type = string
}

variable "tags" {
  description = "Global tags for all resources"
  type        = map(string)
  default = {
    Owner       = "Bernardo"
    Environment = "prod"
    Project     = "TerraformProject"
  }
}


# London variables
variable "vpc_cidr_london" { type = string }
variable "public_subnets_london" { type = list(string) }
variable "private_subnets_london" { type = list(string) }

variable "eks_public_subnets_london" { type = list(string) }
variable "eks_private_subnets_london" { type = list(string) }
variable "azs_london" { type = list(string) }

variable "s3_my-ci-cd-artifacts" {
  type = string
}


variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type = string
}


variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB and load balancers"
  type        = list(string)
}

variable "cluster_version" {
  description = "EKS cluster Kubernetes version"
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}
