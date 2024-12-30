// -----------------------------------------------------------------------------------------------//
// ------------------------------------   TF DATA   ----------------------------------------------//
// -----------------------------------------------------------------------------------------------//

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

# -------------------------------------------------------
# VPC - Subnets
# -------------------------------------------------------
data "aws_vpc" "selected" {
  tags = var.vpc_selection_tags
  filter {
    name   = "isDefault"
    values = [false]
  }
}

data "aws_subnet_ids" "public_subnets" {
  tags   = var.public_subnet_selection_tags
  vpc_id = data.aws_vpc.selected.id
  filter {
    name   = "availability-zone"
    values = local.lc_name_list
  }
}

data "aws_subnet_ids" "private_subnets" {
  tags   = var.private_subnet_selection_tags
  vpc_id = data.aws_vpc.selected.id
  filter {
    name   = "availability-zone"
    values = local.lc_name_list
  }
}

# -------------------------------------------------------
#  KMS
# -------------------------------------------------------
data "aws_kms_key" "kms_cmk_s3" {
  key_id = "alias/${var.app_prefix}-lz-local-s3"
}

data "aws_kms_key" "kms_cmk_rds" {
  key_id = "alias/${var.app_prefix}-lz-local-rds"
}

data "aws_kms_key" "kms_cmk_ebs" {
  key_id = "alias/${var.app_prefix}-lz-local-ebs"
}

data "aws_kms_key" "kms_cmk_backup" {
  key_id = "alias/${var.app_prefix}-lz-local-backup"
}

data "aws_kms_key" "kms_cmk_app" {
  key_id = "alias/${var.app_prefix}-lz-local-app"
}

data "aws_kms_key" "kms_cmk_sns" {
  key_id = "alias/${var.app_prefix}-lz-local-sns"
}



data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

# data "aws_eks_node_group" "infra_nodegroup"{
#   cluster_name = var.eks_cluster_name
#   node_group_name = var.infra_nodegroup_name
# }


### --- Karpenter Requirements ---
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

# data "aws_ami" "eks_hardened_ami" {
#   most_recent = true

#   owners = ["self"]

#   filter {
#     name   = "name"
#     values = ["*eks*"]
#   }
# }
