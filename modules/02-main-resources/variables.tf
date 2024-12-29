variable "master_prefix" {
  description = "Master Prefix for all AWS Resources"
  type        = string
}

variable "env_prefix" {
  description = "Environment Prefix for all AWS Resources"
  type        = string
}

variable "app_prefix" {
  description = "Application Prefix for all AWS Resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

####################################################################################################
## VPC & Subnets Variable Definitions
####################################################################################################

variable "protected_subnet_selection_tags" {
  description = "Tag to be used to select existing Protected Subnets in the VPC to be used to deploy EC2 Instances"
  type        = map(string)
}

variable "private_subnet_selection_tags" {
  description = "Tag to be used to select existing Private Subnets in the VPC to be used to deploy EC2 Instances"
  type        = map(string)
}

variable "public_subnet_selection_tags" {
  description = "Tag to be used to select existing Public Subnets in the VPC to be used to deploy EC2 Instances"
  type        = map(string)
}

variable "vpc_selection_tags" {
  description = "Tag to be used to select existing VPC to be used to deploy AWS resources"
  type        = map(string)
}

variable "number_of_az" {
  description = "Number of AZs"
  type        = number
}

####################################################################################################
## CIDRs Variable Definitions
####################################################################################################

# variable "cicd_tools_cidr" {
#   description = "Prefix list of CICD Tools IP Addresses"
# }

# variable "on_prem_cidr" {
#   description = "List of Onpremise CIDRs for EFS access"
#   type        = list(string)
#   default     = [""]
# }

####################################################################################################
## EC2 Instance Variable Definitions
####################################################################################################

variable "ec2_keypair_name" {
  description = "The Name of EC2 Keypair"
  type        = string
}

variable "bastion_ec2_instance_type" {
  description = "Bastion EC2 Instance Type"
  type        = string
}

variable "bastion_ec2_ebs_optimized" {
  description = "Bastion EC2 EBS Optimized feature gate, enable this if using M5 or C5 instance type"
  type        = bool
}

variable "bastion_ebs_size" {
  description = "Bastion EBS Size"
  type        = number
}

variable "bastion_ebs_type" {
  description = "Bastion EBS Type"
  type        = string
}

variable "bastion_ebs_iops" {
  description = "Bastion EBS IOPS"
  type        = number
  default     = null
}

variable "bastion_ebs_throughput" {
  description = "Bastion EBS Throughput"
  type        = number
  default     = null
}


####################################################################################################
## ECR Parameters
####################################################################################################

# variable "ecr_repositories" {
#   type = map
#   description = "map of ECR repositories, along with their parameters"
# }

variable "elasticache_redis_clusters" {
  description = "List of Elasticache Redis instances to be provisioned"
}

variable "ec2_hardened_ami_id" {
  type = string
}

variable "eks_hardened_ami_id" {
  type = string
}

variable "eks_cluster_version" {
  type = string
}

variable "infra_ng_min_size" {
  type = number
}
variable "infra_ng_max_size" {
  type = number
}
variable "infra_ng_desired_size" {
  type = number
}

variable "jenkins_iam_user_name" {
  type    = string
  default = "jenkins"
}

variable "cloudwatch_log_group_retention_in_days" {
  type = number
}

variable "terraform_executor_role_name" {
  type        = string
  description = "name for terraform executor role, this role will be assume by jenkins worker from devops account"
  default     = "TerraformExecutor"
}

variable "lz_admin_role_name" {
  type        = string
  description = "LZ admin role name"
  # default     = "AWSReservedSSO_LZ-Administrator"
}

variable "gl_runner_role_name" {
  type        = string
  description = "gl runner role name"
}

variable "cloudfront_distribution_arn" {
  type = string
}