resource "aws_instance" "ec2_bastion" {
  disable_api_termination              = true
  monitoring                           = true
  ebs_optimized                        = var.bastion_ec2_ebs_optimized
  instance_initiated_shutdown_behavior = "stop"

  ami                    = var.ec2_hardened_ami_id
  subnet_id              = tolist(data.aws_subnet_ids.private_subnets.ids)[0]
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_bastion_instance_profile.id
  key_name               = var.ec2_keypair_name
  user_data_base64       = base64encode(data.template_file.bastion_userdata.rendered)
  instance_type          = var.bastion_ec2_instance_type

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = "2"
  }

  ebs_block_device {
    volume_type = var.bastion_ebs_type
    volume_size = var.bastion_ebs_size
    device_name = "/dev/xvda"
    encrypted             = true
    kms_key_id            = data.aws_kms_key.kms_cmk_ebs.arn
    delete_on_termination = true
    tags                  = var.tags
  }

  tags = merge({
    "Name" = format("%s-bastion", local.general_prefix)
  }, var.tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
