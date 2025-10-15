variable "vpc_name" { 
    type = string 
    }


variable "vpc_cidr" { 
    type = string 
    }

variable "public_subnets" { 
    type = list(string) 
    }

variable "private_subnets" { 
    type = list(string) 
    }

variable "azs" { 
    type = list(string) 
    }

variable "eks_public_subnets" {
  type    = list(string)
  default = []
}

variable "eks_private_subnets" {
  type    = list(string)
  default = []
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region for naming subnets"
  type        = string
}
