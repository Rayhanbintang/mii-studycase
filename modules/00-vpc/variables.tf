variable "region" {
  type = string
}

variable "master_prefix" {
  description = "Master preix to be used for all AWS resources"
  type        = string
}

variable "env_prefix" {
  description = "Environment specific prefix to be used for all AWS resources"
  type        = string
}

variable "app_prefix" {
  description = "Application Prefix for all AWS Resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr_block" {
}

variable "number_of_az" {
}

variable "used_az" {

}

variable "public_subnet_cidr_blocks" {
}

variable "private_subnet_cidr_blocks" {
}

variable "protected_subnet_cidr_blocks" {
}

variable "kms_list" {
  type = map(any)
}