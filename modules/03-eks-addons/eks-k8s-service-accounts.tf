# resource "kubernetes_service_account" "cluster_autoscaler_service_account" {
#   metadata {
#     namespace = "kube-system"
#     name      = "cluster-autoscaler"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.cluster_autoscaler_irsa_role.iam_role_arn
#     }
#   }
# }

#Kubernetes Service Account for Add-ons
resource "kubernetes_service_account" "load_balancer_controller_service_account" {
  metadata {
    namespace = "kube-system"
    name      = "aws-load-balancer-controller"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.load_balancer_controller_irsa_role.iam_role_arn
    }
  }
}


# resource "kubernetes_service_account" "karpenter_service_account" {
#   metadata {
#     namespace = "karpenter"
#     name      = "karpenter"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.karpenter_irsa_role.iam_role_arn
#     }
#   }
# }