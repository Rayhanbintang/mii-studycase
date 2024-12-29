// -----------------------------------------------------------------------------------------------//
// --------------------------------   TAGS VARIABLE   --------------------------------------------//
// -----------------------------------------------------------------------------------------------//
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
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

module "main_resources" {
  source = "../../modules/02-main-resources"
  tags   = var.tags
  
}