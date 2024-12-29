resource "aws_vpc" "vpc" {
  # checkov:skip=CKV2_AWS_11: This VPC is for testing purpose, no need for VPC logging
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = format("%s-%s-vpc", var.env_prefix, var.app_prefix)
  }
}