resource "aws_security_group" "bastion" {
  # checkov:skip=CKV2_AWS_5: This SG is attached to EC2 Instance
  name        = format("%s-bastion-sg", local.general_prefix)
  description = "Allow bastion traffic"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = format("%s-bastion-sg", local.general_prefix)
  }
}

# resource "aws_security_group" "elasticache_redis_sg" {
#   # checkov:skip=CKV2_AWS_5: This SG is attached to Elasticache Redis
#   for_each = { for cluster in var.elasticache_redis_clusters : cluster.name => cluster }
#   name_prefix = format("%s-%s-sg", local.general_prefix, each.value.name)
#   vpc_id      = data.aws_vpc.selected.id
#   description = "SG for Elasticache Redis"

#   ingress {
#     description = "Allow incoming access to Elasticache Redis from Bastion"
#     from_port   = each.value.redis_port
#     to_port     = each.value.redis_port
#     protocol    = "tcp"
#     security_groups = [aws_security_group.bastion.id]
#   }

#   ingress {
#     description = "Allow incoming access to Elasticache Redis from EKS Nodes & Pods"
#     from_port   = each.value.redis_port
#     to_port     = each.value.redis_port
#     protocol    = "tcp"
#     security_groups = [module.eks-cluster.node_security_group_id]
#   }

#   tags = {
#     "Name" = format("%s-%s-sg", local.general_prefix, each.value.name)
#   }
# }
