resource "aws_subnet" "public_subnets" {
  count             = var.number_of_az
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.used_az[count.index]
  cidr_block        = var.public_subnet_cidr_blocks[count.index]

  tags = {
    Name       = format("%s-%s-%s-subnet-%s", var.env_prefix, var.app_prefix, "public", count.index + 1)
    SubnetType = "Public"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = var.number_of_az
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.used_az[count.index]
  cidr_block        = var.private_subnet_cidr_blocks[count.index]

  tags = {
    Name       = format("%s-%s-%s-subnet-%s", var.env_prefix, var.app_prefix, "private", count.index + 1)
    SubnetType = "Private"
  }
}

resource "aws_subnet" "protected_subnets" {
  count             = var.number_of_az
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.used_az[count.index]
  cidr_block        = var.protected_subnet_cidr_blocks[count.index]

  tags = {
    Name       = format("%s-%s-%s-subnet-%s", var.env_prefix, var.app_prefix, "protected", count.index + 1)
    SubnetType = "Protected"
  }
}