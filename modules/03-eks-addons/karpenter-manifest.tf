terraform {
  required_version = ">= 1.0.7"
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  load_config_file       = false
  # token                  = data.aws_eks_cluster_auth.cluster.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
  }
}

#TODO: ADJUST SIZING BASED ON ENVIRONMENT

resource "kubectl_manifest" "karpenter_example_deployment" {
  yaml_body = <<-YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: inflate
    spec:
      replicas: 0
      selector:
        matchLabels:
          app: inflate
      template:
        metadata:
          labels:
            app: inflate
        spec:
          terminationGracePeriodSeconds: 0
          containers:
            - name: inflate
              image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
              resources:
                requests:
                  cpu: 10m
          nodeSelector:
            purpose: backend
  YAML
}


### === talentjs workload instance SPEC ===
resource "kubectl_manifest" "workload_provisioner" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: talentjs
    spec:
      providerRef:
        name: talentjs
      labels:
        purpose: talentjs
      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["c"]
        - key: "karpenter.k8s.aws/instance-family"
          operator: In
          values: ["c6g"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["1", "2", "4"]
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values: ["nitro"]
        - key: "topology.kubernetes.io/zone"
          operator: In
          values: ${jsonencode(local.lc_name_list)}
        - key: "kubernetes.io/arch"
          operator: In
          values: ["arm64"]
        - key: "karpenter.sh/capacity-type" # If not included, the webhook for the AWS cloud provider will default to on-demand
          operator: In
          values: ["on-demand"]
      kubeletConfiguration:
        containerRuntime: containerd
        maxPods: 110
      limits:
        resources:
          cpu: ${var.workload_cpu}
      consolidation:
        enabled: true
      ttlSecondsUntilExpired: 86400 # 1 Day(s) = 1 * 24 * 60 * 60 Seconds
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "talentjs_karpenter_node_template" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: talentjsextension
    spec:
      subnetSelector:
        karpenter.sh/discovery: ${var.eks_cluster_name}
      securityGroupSelector:
        karpenter.sh/discovery: ${var.eks_cluster_name}
      amiSelector: 
        aws-ids: ${var.eks_hardened_graviton_ami_id}
      # instanceProfile: ${var.infra_node_group_role_arn}
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeSize: 50Gi
            volumeType: gp3
            iops: 3000
            encrypted: true
            kmsKeyID: ${data.aws_kms_key.kms_cmk_ebs.arn} 
            deleteOnTermination: true
            throughput: 125
      tags:
        karpenter.sh/discovery: ${var.eks_cluster_name}
        ApplicationName : "talentjs"
        ApplicationId : "talentjs"
  YAML

  depends_on = [
    module.karpenter
  ]
}

