# EKS Cluster Variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Whether the Kubernetes API server endpoint is publicly accessible"
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Whether the Kubernetes API server endpoint is privately accessible"
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
}

variable "service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from"
  type        = string
}

variable "enabled_cluster_log_types" {
  description = "List of log types to enable for the EKS cluster"
  type        = list(string)
}

variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    node_role_arn      = string
    subnet_ids         = list(string)
    capacity_type      = string
    instance_types     = list(string)
    desired_size       = number
    max_size           = number
    min_size           = number
    update_max_unavailable = number
  }))
  default = {}
}

# London-specific network variables
variable "vpc_cidr_london" {
  description = "CIDR block for the London VPC"
  type        = string
}

variable "public_subnets_london" {
  description = "Public subnets for London"
  type        = list(string)
}

variable "private_subnets_london" {
  description = "Private subnets for London"
  type        = list(string)
}

variable "eks_public_subnets_london" {
  description = "EKS public subnets for load balancers in London"
  type        = list(string)
}

variable "eks_private_subnets_london" {
  description = "EKS private subnets for worker nodes in London"
  type        = list(string)
}

# Other variables
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "region_london" {
  description = "London region"
  type        = string
  default     = "eu-west-2"
}

variable "region_ireland" {
  description = "London region"
  type        = string
  default     = "eu-west-1"
}

variable "azs_london" {
  description = "Availability zones for London"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}

variable "key_name" {
  description = "KMS key name"
  type        = string
}

variable "s3_my-ci-cd-artifacts" {
  description = "S3 bucket name for CI/CD artifacts"
  type        = string
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch"
  type        = string
}

