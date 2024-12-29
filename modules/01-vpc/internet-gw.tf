resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s-%s-igw", var.env_prefix, var.app_prefix)
  }
}