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

variable "s3_tags" {
  description = "Additional tags for S3 resources"
  type        = map(string)
  default     = {}
}

variable "dynamodb_tags" {
  description = "Additional tags for DynamoDB resources"
  type        = map(string)
  default     = {}
}

