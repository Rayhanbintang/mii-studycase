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
variable "elasticache_redis_clusters" {
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

  bastion_ec2_instance_type = "t3.nano"
  bastion_ec2_ebs_optimized = true #enable this when using instance type that listed here https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-optimized.html#ebs-optimization-support
  bastion_ebs_size          = 50
  bastion_ebs_type          = "gp3"
  bastion_ebs_iops          = 3000 #set this value if using gp3 or io1
  bastion_ebs_throughput    = 125  #set this value if using gp3 or io1
  ec2_keypair_name          = "bastion-keypair"


  elasticache_redis_clusters = var.elasticache_redis_clusters
}