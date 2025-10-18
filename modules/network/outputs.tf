# VPC ID
output "vpc_id" { 
  value = aws_vpc.main.id 
}

# VPC cidr block
output "vpc_cidr_block" { 
  value = aws_vpc.main.cidr_block 
}

# Public Subnets
output "public_subnet_ids" { 
  value = aws_subnet.public[*].id 
}

# Private Subnets  
output "private_subnet_ids" { 
  value = aws_subnet.private[*].id 
}

# EKS Public Subnets - FIXED: reference the correct EKS public subnets
output "eks_public_subnet_ids" { 
  value = aws_subnet.eks_public[*].id 
}

# EKS Private Subnets - FIXED: reference the correct EKS private subnets
output "eks_private_subnet_ids" { 
  value = aws_subnet.eks_private[*].id 
}

# EKS Private Route Table
output "eks_private_route_table_id" {
  value = aws_route_table.eks_private.id
}

# Public Route Table
output "public_route_table_id" { 
  value = aws_route_table.public.id 
}

# VPC IGTW
output "internet_gateway_id" { 
  value = aws_internet_gateway.igw.id 
}

# Public Route Table Associations
output "public_route_table_associations" { 
  value = aws_route_table_association.public_assoc[*].id 
}