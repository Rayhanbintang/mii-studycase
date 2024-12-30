# module "cluster_autoscaler_irsa_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name                        = format("%s_%s_cluster_autoscaler", var.env_prefix, var.app_prefix)
#   attach_cluster_autoscaler_policy = true

#   cluster_autoscaler_cluster_ids = [var.eks_cluster_name]

#   oidc_providers = {
#     main = {
#       provider_arn               = var.eks_oidc_provider_arn
#       namespace_service_accounts = ["kube-system:cluster-autoscaler"]
#     }
#   }
# }

module "load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  # role_name                              = "load_balancer_controller"
  role_name                              = format("%s_%s_load_balancer_controller", var.env_prefix, var.app_prefix)
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

### --- Karpenter Requirements ---
# module "karpenter_irsa_role" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   # role_name                          = "karpenter_controller"
#   role_name                        = format("%s_%s_karpenter", var.env_prefix, var.app_prefix)
#   attach_karpenter_controller_policy = true

#   # karpenter_controller_cluster_id         = var.eks_cluster_id
#   karpenter_controller_node_iam_role_arns = [var.infra_node_group_role_arn]

#   attach_vpc_cni_policy = true
#   vpc_cni_enable_ipv4   = true

#   oidc_providers = {
#     main = {
#       provider_arn               = var.eks_oidc_provider_arn
#       namespace_service_accounts = ["karpenter:karpenter"]
#     }
#   }
# }

### Karpenter module
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "= 19.21"

  cluster_name = data.aws_eks_cluster.cluster.name

  irsa_oidc_provider_arn          = var.eks_oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  create_iam_role = false
  # iam_role_arn    = module.eks.eks_managed_node_groups["initial"].iam_role_arn
  iam_role_arn = var.infra_node_group_role_arn

}
