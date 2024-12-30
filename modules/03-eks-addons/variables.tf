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

variable "number_of_az" {
  description = "Number of AZs"
  type        = number
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

variable "eks_cluster_name" {
  type = string
}

variable "eks_oidc_provider_arn" {
  type = string
}


variable "ec2_hardened_ami_id" {
  type = string
}

variable "eks_hardened_ami_id" {
  type = string
}

variable "eks_hardened_graviton_ami_id" {
  type = string
}

### --- Karpenter Requirements ---
variable "infra_node_group_role_arn" {
  type = string
}

variable "karpenter_version" {
  type = string
}

# variable "eks_cluster_endpoint" {
#   type = string
# }

# variable "eks_cluster_id" {
#   type = string
# }

####################################################################################################
## Fluentbit
####################################################################################################

variable "fluentbit_splunk_host" {
  type = string
  description = "NLB from the splunk account"
}

variable "fluentbit_splunk_port" {
  type = string
  description = "splunk port"
}

variable "fluentbit_splunk_token" {
  type = string
  description = "splunk token"
}

variable "fluentbit_splunk_index" {
  type = string
  description = "splunk index"
}

variable "fluentbit_splunk_sourcetpye" {
  type = string
  description = "splunk sourcetype"
}

variable "appsvc_cpu" {
  type = string
  description = "vCPU count for app svc"
}


variable "apigw_cpu" {
  type = string
  description = "vCPU count for api gw"
}

variable "konggw_cpu" {
  type = string
  description = "vCPU count for app svc"
}


variable "backend_cpu" {
  type = string
  description = "vCPU count for api gw"
}