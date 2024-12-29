module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"
  name    = "my-vpc"
  cidr    = "10.0.0.0/16"

  azs             = ["ap-southeast-3a", "ap-southeast-3b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
