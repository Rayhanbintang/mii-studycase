resource "aws_iam_instance_profile" "ec2_bastion_instance_profile" {
  name = format("%s-bastion-profile", local.general_prefix)
  role = aws_iam_role.ec2_bastion_instance_role.name
  tags = {
    "Name" = format("%s-bastion-profile", local.general_prefix)
  }
}

resource "aws_iam_role" "ec2_bastion_instance_role" {
  name = format("%s-instance-role", local.general_prefix)

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    format("arn:aws:iam::%s:policy/lz-SSMProfilePolicy-ap-southeast-3", data.aws_caller_identity.current.account_id)
  ]

  inline_policy {
    name = "write_to_cw"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:PutMetricData",
            "ec2:DescribeVolumes",
            "ec2:DescribeTags",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams",
            "logs:DescribeLogGroups",
            "logs:CreateLogStream"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup"
          ],
          "Resource" : "arn:aws:logs:*:*:log-group:*:log-stream:*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameter"
          ],
          "Resource" : "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeNetworkInterfaces",
            "ec2:AttachNetworkInterface",
            "ec2:UnassignPrivateIpAddresses",
            "ec2:AssignPrivateIpAddresses"
          ],
          "Resource" : "*"
        },
      ]
    })
  }

  inline_policy {
    name = "read_access_to_kms"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [{
        "Effect" : "Allow",
        "Action" : ["kms:DescribeKey", "kms:GenerateDataKey", "kms:Encrypt", "kms:Decrypt"],
        "Resource" : data.aws_kms_key.kms_cmk_ebs.arn
      }]
    })
  }

  tags = {
    "Name" = format("%s-bastion-profile", local.general_prefix)
  }
}

