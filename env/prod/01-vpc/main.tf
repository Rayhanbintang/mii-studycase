// -----------------------------------------------------------------------------------------------//
// --------------------------------   TAGS VARIABLE   --------------------------------------------//
// -----------------------------------------------------------------------------------------------//
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "app_master_prefix" {
  type = string
}

variable "app_env_prefix" {
  type = string
}

variable "app_name_prefix" {
  type = string
}




// -----------------------------------------------------------------------------------------------//
// --------------------------------   TF PROVIDER   ----------------------------------------------//
// -----------------------------------------------------------------------------------------------//
provider "aws" {
  region                 = "ap-southeast-3"
  skip_region_validation = true
  default_tags {
    tags = var.tags
  }
}



// -----------------------------------------------------------------------------------------------//
// --------------------------------   TF BACKEND   -----------------------------------------------//
// -----------------------------------------------------------------------------------------------//
terraform {

  // Backend for storing the State File (S3) & State-Lock (DynamoDB)
  #TODO: Need to change the Bucket & DynamoDB table name
  backend "s3" {
    bucket                 = ""
    region                 = "ap-southeast-3"
    skip_region_validation = true
    key                    = "01-vpc/terraform.tfstate"
    dynamodb_table         = ""
    encrypt                = true
  }
}

// -----------------------------------------------------------------------------------------------//
// --------------------------------   TF VERSION   -----------------------------------------------//
// -----------------------------------------------------------------------------------------------//
terraform {
  required_version = ">= 1.0.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
    # kubectl = {
    #   source  = "gavinbunney/kubectl"
    #   version = "~> 1.14"
    # }
  }
}


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

