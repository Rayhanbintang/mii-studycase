// -----------------------------------------------------------------------------------------------//
// --------------------------------   TF INPUT VARIABLES   ---------------------------------------//
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
// --------------------------------   TF VERSION   -----------------------------------------------//
// -----------------------------------------------------------------------------------------------//
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

// -----------------------------------------------------------------------------------------------//
// --------------------------------   TF PROVIDER   ----------------------------------------------//
// -----------------------------------------------------------------------------------------------//
provider "aws" {
  region = "ap-southeast-3"
}


// -----------------------------------------------------------------------------------------------//
// --------------------------------   TF MODULES   -----------------------------------------------//
// -----------------------------------------------------------------------------------------------//
module "prereq" {
  source = "../../../modules/00-terraform-prereq"

  region        = "ap-southeast-3"
  master_prefix = var.app_master_prefix
  env_prefix    = var.app_env_prefix
  app_prefix    = var.app_name_prefix
}


// -----------------------------------------------------------------------------------------------//
// --------------------------------   OUTPUTS   -----------------------------------------------//
// -----------------------------------------------------------------------------------------------//
output "tfstate_s3_bucket_name" {
  value = module.prereq.tfstate_s3_bucket_name
}

output "tfstate_lock_dynamodb_name" {
  value = module.prereq.tfstate_lock_dynamodb_name
}
