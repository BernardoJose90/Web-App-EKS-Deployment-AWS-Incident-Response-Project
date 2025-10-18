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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
