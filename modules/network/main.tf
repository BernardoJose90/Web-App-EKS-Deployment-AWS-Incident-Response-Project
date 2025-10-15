terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, { Name = "${var.vpc_name}-vpc" })
}

# Data source for the default/main route table
data "aws_route_tables" "main_for_vpc" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }

  filter {
    name   = "association.main"
    values = ["true"]
  }
}


resource "aws_ec2_tag" "default_rt_name" {
  resource_id = data.aws_route_tables.main_for_vpc.ids[0]
  key         = "Name"
  value       = "${var.vpc_name}-default-rt"
}




# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-${var.region}-${var.vpc_name}-public-${var.azs[count.index]}"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-${var.region}-${var.vpc_name}-private-${var.azs[count.index]}"
    }
  )
}

# Eks_Public Subnets
resource "aws_subnet" "eks_public" {
  count             = length(var.eks_public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.eks_public_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-${var.region}-${var.vpc_name}-eks_public-${var.azs[count.index]}"
    }
  )
}

# Eks_Private Subnets
resource "aws_subnet" "eks_private" {
  count             = length(var.eks_private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.eks_private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-${var.region}-${var.vpc_name}-eks_private-${var.azs[count.index]}"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.tags["Environment"]}-${var.vpc_name}-igw-${var.region}" })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, { Name = "${var.vpc_name}-public-rt" })
}

# EKS Private Route Table
resource "aws_route_table" "eks_private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-eks-private-rt"
  })
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate eksprivate Subnets with Route Table
resource "aws_route_table_association" "eks_private_assoc" {
  count          = length(var.eks_private_subnets)
  subnet_id      = aws_subnet.eks_private[count.index].id
  route_table_id = aws_route_table.eks_private.id
}
