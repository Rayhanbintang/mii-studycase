module "eks-cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = format("%s-%s-eks", var.env_prefix, var.app_prefix)
  # cluster_version = "1.24" 
  cluster_version = var.eks_cluster_version

  kms_key_administrators = [
    data.aws_iam_role.terraformexecutor.arn, 
    data.aws_iam_role.lz_admin_role.arn,
    data.aws_iam_role.gl_runner_role_name.arn
  ]

  cluster_timeouts = {
    create  = "30m"
    destroy = "30m"
  }

  #TODO: cluster_endpoint_public_access need to be set to true during provisioning, and can be disabled after the provisioning of EKS Add-ons is completed
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  enable_irsa                     = true

  cluster_addons = {
    coredns = {
      # most_recent           = true
      addon_version           = "v1.10.1-eksbuild.11"
      resolve_conflicts       = "PRESERVE"
    }
    kube-proxy = {
      # most_recent           = true
      addon_version           = "v1.27.10-eksbuild.2"
      resolve_conflicts       = "PRESERVE"
    }
    vpc-cni = {
      # most_recent = true
      addon_version            = "v1.18.1-eksbuild.3"
      resolve_conflicts        = "PRESERVE"
    }
    aws-ebs-csi-driver = {
      # most_recent              = true
      addon_version              = "v1.31.0-eksbuild.1"
      resolve_conflicts          = "PRESERVE"
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  vpc_id                   = data.aws_vpc.selected.id
  subnet_ids               = data.aws_subnet_ids.private_subnets.ids
  control_plane_subnet_ids = data.aws_subnet_ids.private_subnets.ids

  cluster_security_group_additional_rules = {
    bastion_access = {
      protocol    = "TCP"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      description = "Allow Kubernetes API Access from Bastion"
      # cidr_blocks              = 
      # ipv6_cidr_blocks         = 
      # prefix_list_ids          = 
      # self                     = 
      source_security_group_id = aws_security_group.bastion.id
    }
  }

  node_security_group_tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = format("%s-%s-eks", var.env_prefix, var.app_prefix)
  }


  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    capacity_type           = "ON_DEMAND"
    ebs_optimized           = true
    disable_api_termination = false
    enable_monitoring       = true

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 50
          volume_type = "gp3"
          iops        = 3000
          throughput  = 125
          #TODO: Set the EBS Encryption to true & Set the KMS-CMK ID
          encrypted             = true
          kms_key_id            = data.aws_kms_key.kms_cmk_ebs.arn
          delete_on_termination = true
        }
      }
    }

    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      lz-SSMProfilePolicy          = format("arn:aws:iam::%s:policy/lz-SSMProfilePolicy-%s", data.aws_caller_identity.current.account_id, data.aws_region.current.name)
    }

    use_name_prefix = true

    use_custom_launch_template = true
    #TODO: Set the EKS AMI ID with the custom/hardened AMI ID
    ami_id = var.eks_hardened_ami_id

    # By default, EKS managed node groups will not append bootstrap script;
    # this adds it back in using the default template provided by the module
    # Note: this assumes the AMI provided is an EKS optimized AMI derivative
    enable_bootstrap_user_data = true

    pre_bootstrap_user_data = <<-EOT
      #!/bin/bash
      set -ex
      cat <<-EOF > /etc/profile.d/bootstrap.sh
      export CONTAINER_RUNTIME="containerd"
      export USE_MAX_PODS=false
      export KUBELET_EXTRA_ARGS="--max-pods=110"
      EOF
      # Source extra environment variables in bootstrap script
      sed -i '/^set -o errexit/a\\nsource /etc/profile.d/bootstrap.sh' /etc/eks/bootstrap.sh
    EOT

    # Because we have full control over the user data supplied, we can also run additional
    # scripts/configuration changes after the bootstrap script has been run
    post_bootstrap_user_data = <<-EOT
      echo "EKS Node Bootstrap Complete!"
    EOT
  }

  eks_managed_node_groups = {
    infra = {
      name                  = format("infra-%s-%s", var.env_prefix, var.app_prefix)
      instance_types        = var.infra_instance_types
      capacity_type         = "ON_DEMAND"
      create_security_group = false

      min_size     = var.infra_ng_min_size
      max_size     = var.infra_ng_max_size
      desired_size = var.infra_ng_desired_size

      labels = {
        purpose = "infra"
      }
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = false

  cluster_enabled_log_types = [
    # "audit",
    # "api",
    # "authenticator",
    # "controllerManager",
    # "scheduler"
  ]
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  # tags = var.tags
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "ebs_csi"
  attach_ebs_csi_policy = true
  ebs_csi_kms_cmk_ids   = ["${data.aws_kms_key.kms_cmk_ebs.arn}"]

  oidc_providers = {
    main = {
      provider_arn               = module.eks-cluster.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}