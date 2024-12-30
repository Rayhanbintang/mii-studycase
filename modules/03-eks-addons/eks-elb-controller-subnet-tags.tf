resource "aws_ec2_tag" "elb_controller_public_subnet_tag" {
  for_each    = data.aws_subnet_ids.public_subnets.ids
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "elb_controller_private_subnet_tag" {
  for_each    = data.aws_subnet_ids.private_subnets.ids
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "karpenter_private_subnet_tag" {
  for_each    = data.aws_subnet_ids.private_subnets.ids
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.eks_cluster_name
}