resource "aws_network_acl" "public_subnet_nacl" {
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 201
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol = "-1"
    rule_no  = 200
    action   = "allow"
    # cidr_block = var.vpc_cidr_block
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 202
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 203
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = format("%s-%s-%s-subnet-nacl", var.env_prefix, var.app_prefix, "public")
  }
}

resource "aws_network_acl" "private_subnet_nacl" {
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 201
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol = "-1"
    rule_no  = 200
    action   = "allow"
    # cidr_block = var.vpc_cidr_block
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 202
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 203
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name    = format("%s-%s-%s-subnet-nacl", var.env_prefix, var.app_prefix, "private")
    Purpose = "web"
  }
}

resource "aws_network_acl" "protected_subnet_nacl" {
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 201
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = var.vpc_cidr_block
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = format("%s-%s-%s-subnet-nacl", var.env_prefix, var.app_prefix, "protected")
  }
}


resource "aws_network_acl_association" "public_subnet_nacl_assoc" {
  count          = var.number_of_az
  network_acl_id = aws_network_acl.public_subnet_nacl.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_network_acl_association" "private_subnet_nacl_assoc" {
  count          = var.number_of_az
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

resource "aws_network_acl_association" "protected_subnet_nacl_assoc" {
  count          = var.number_of_az
  network_acl_id = aws_network_acl.protected_subnet_nacl.id
  subnet_id      = aws_subnet.protected_subnets[count.index].id
}