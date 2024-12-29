resource "aws_route_table" "public_route_tables" {
  count  = var.number_of_az
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }

  tags = {
    Name = format("%s-%s-%s-subnet-%s-rt", var.env_prefix, var.app_prefix, "public", count.index + 1)
  }
}

resource "aws_route_table" "private_route_tables" {
  count  = var.number_of_az
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name    = format("%s-%s-%s-subnet-%s-rt", var.env_prefix, var.app_prefix, "private", count.index + 1)
    Purpose = "Private RouteTable"
  }
}

resource "aws_route_table" "protected_route_tables" {
  count  = var.number_of_az
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = format("%s-%s-%s-subnet-%s-rt", var.env_prefix, var.app_prefix, "protected", count.index + 1)
  }
}

resource "aws_route_table_association" "public_subnet_rt_attach" {
  count          = var.number_of_az
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_tables[count.index].id
}

resource "aws_route_table_association" "private_subnet_rt_attach" {
  count          = var.number_of_az
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}

resource "aws_route_table_association" "protected_subnet_rt_attach" {
  count          = var.number_of_az
  subnet_id      = aws_subnet.protected_subnets[count.index].id
  route_table_id = aws_route_table.protected_route_tables[count.index].id
}