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

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "demodb"

  engine            = "postgresql"
  engine_version    = "12.22"
  instance_class    = "db.m6g.2xlarge"
  allocated_storage = 500

  db_name  = "talentjsdb"
  username = "user"
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = ["sg-12345678"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = [{var.private_subnets}]

  # DB parameter group
  family = "postgresql12"

  # DB option group
  major_engine_version = "12.22"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}