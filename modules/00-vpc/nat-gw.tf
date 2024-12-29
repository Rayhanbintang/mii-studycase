resource "aws_eip" "nat_gw_eip_allocation" {
  # count = var.number_of_az
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  # count = var.number_of_az
  # subnet_id     = aws_subnet.public_subnets[count.index].id
  # allocation_id = aws_eip.nat_gw_eip_allocation[count.index].id

  allocation_id = aws_eip.nat_gw_eip_allocation.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "nat-gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  # depends_on = [aws_internet_gateway.example]
}