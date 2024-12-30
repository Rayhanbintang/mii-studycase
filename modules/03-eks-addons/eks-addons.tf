#Add-ons Installation using Helm
resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [
    kubernetes_service_account.load_balancer_controller_service_account
  ]
  namespace  = "kube-system"
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.4.7"

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }
  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }
  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "ingressClassParams.create"
    value = "false"
  }

  set {
    name  = "createIngressClassResource"
    value = "false"
  }
}

# resource "helm_release" "cluster_autoscaler" {
#   depends_on = [
#     kubernetes_service_account.cluster_autoscaler_service_account
#   ]
#   namespace  = "kube-system"
#   name       = "cluster-autoscaler"
#   chart      = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   version    = "9.21.1"

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = var.eks_cluster_name
#   }
#   set {
#     name  = "rbac.serviceAccount.create"
#     value = "false"
#   }
#   set {
#     name  = "rbac.serviceAccount.name"
#     value = "cluster-autoscaler"
#   }

#   set {
#     name = "awsRegion"
#     value = data.aws_region.current.name
#   }
# }

resource "helm_release" "metrics_server" {
  namespace  = "kube-system"
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  version    = "3.8.4"

  # set {
  #   name  = "hostNetwork.enabled"
  #   value = true
  # }
}

# resource "helm_release" "cw_container_insights_otel" {
#   name       = "cw-container-insights-otel"
#   chart      = "adot-exporter-for-eks-on-ec2"
#   repository = "https://aws-observability.github.io/aws-otel-helm-charts"
#   # version    = ""

#   set {
#     name  = "awsRegion"
#     value = data.aws_region.current.name
#   }

#   set {
#     name  = "clusterName"
#     value = var.eks_cluster_name
#   }

#   set {
#     name  = "adotCollector.daemonSet.service.metrics.receivers"
#     value = "{awscontainerinsightreceiver}"
#   }

#   set {
#     name  = "adotCollector.daemonSet.service.metrics.exporters"
#     value = "{awsemf}"
#   }

#   set {
#     name  = "fluentbit.enabled"
#     value = "true"
#   }
# }

# resource "helm_release" "fluentbit" {
#   namespace        = "amazon-logging"
#   create_namespace = true
#   name             = "fluent"
#   chart            = "fluent-bit"
#   repository       = "https://fluent.github.io/helm-charts"
#   # version    = ""

#   values = [
#     "${file("${path.module}/manifests/fluentbit-helm/values-ops.yml")}"
#   ]

#   set {
#     name  = "aws_region"
#     value = data.aws_region.current.name
#   }

#   set {
#     name  = "eks_cluster_name"
#     value = var.eks_cluster_name
#   }

#   set {
#     name  = "splunk_token"
#     value = var.fluentbit_splunk_token
#   }

#   set {
#     name  = "splunk_host"
#     value = var.fluentbit_splunk_host
#   }

#   set {
#     name  = "splunk_port"
#     value = var.fluentbit_splunk_port
#   }

#   set {
#     name = "K8S-Logging.Exclude"
#     value = "on"
#   }

#   set {
#     name = "splunk_index"
#     value = var.fluentbit_splunk_index
#   }

#   set {
#     name = "splunk_sourcetype"
#     value = var.fluentbit_splunk_sourcetpye
#   }
# }


### --- Karpenter Requirements ---
resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  # repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  # repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = var.karpenter_version

  set {
    name  = "settings.aws.clusterName"
    value = data.aws_eks_cluster.cluster.name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = data.aws_eks_cluster.cluster.endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }
  
  set {
    name  = "featureGates.driftEnabled"
    value = true
  }

  set {
    name  = "nodeSelector"
    value = "purpose: infra"
  }

  # set {
  #   name = "controller.resources"
  #   value = {"limits":{"cpu":1,"memory":"1Gi"},"requests":{"cpu":1,"memory":"1Gi"}}
  # }
}