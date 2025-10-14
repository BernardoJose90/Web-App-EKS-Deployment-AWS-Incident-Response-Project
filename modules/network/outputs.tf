output "vpc_id" { 
    value = aws_vpc.main.id 
    }

output "public_subnets" { 
    value = aws_subnet.public[*].id 
    }

output "private_subnets" { 
    value = aws_subnet.private[*].id 
    }

output "internet_gateway_id" { 
    value = aws_internet_gateway.igw.id 
    }

output "public_route_table_id" { 
    value = aws_route_table.public.id 
    }

output "public_route_table_associations" { 
    value = aws_route_table_association.public_assoc[*].id 
    }

output "vpc_cidr_block" { 
    value = aws_vpc.main.cidr_block 
    }   
