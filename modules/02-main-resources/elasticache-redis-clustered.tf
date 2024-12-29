resource "aws_elasticache_subnet_group" "elasticache_redis_subnetgroup" {
  name       = format("%s-redis-subnet-group", local.general_prefix)
  subnet_ids = tolist(data.aws_subnet_ids.protected_subnets.ids)
}


resource "aws_elasticache_parameter_group" "elasticache_redis_param_group" {
  for_each = { for cluster in var.elasticache_redis_clusters : cluster.name => cluster }
  name     = format("%s-param-group", each.value.name)
  family   = each.value.redis_family

  dynamic "parameter" {
    for_each = each.value.cluster_mode_enabled ? concat([{ name = "cluster-enabled", value = "yes" }], each.value.redis_additional_parameters) : each.value.redis_additional_parameters
    content {
      name  = parameter.value.name
      value = tostring(parameter.value.value)
    }
  }

  # Ignore changes to the description since it will try to recreate the resource
  lifecycle {
    ignore_changes = [
      description
    ]
  }

  tags = {
    "Name" = format("%s-param-group", each.value.name)
  }
}

resource "aws_elasticache_replication_group" "redis_cluster" {
  # checkov:skip=CKV2_AWS_50: Multi-AZ Auto-failover is toggled by variable
  # checkov:skip=CKV_AWS_29: At Rest Encryption is toggled by variable
  # checkov:skip=CKV_AWS_30: In Transit Encryption is toggled by variable
  for_each                   = { for cluster in var.elasticache_redis_clusters : cluster.name => cluster }
  replication_group_id       = each.value.name
  description                = each.value.description
  node_type                  = each.value.instance_type
  num_cache_clusters         = each.value.cluster_mode_enabled ? null : each.value.cluster_nodes
  num_node_groups            = each.value.cluster_mode_enabled ? each.value.shards : null
  replicas_per_node_group    = each.value.replicas_per_shard
  port                       = each.value.redis_port
  parameter_group_name       = aws_elasticache_parameter_group.elasticache_redis_param_group[each.value.name].name
  automatic_failover_enabled = each.value.cluster_mode_enabled ? true : each.value.automatic_failover_enabled
  multi_az_enabled           = each.value.multi_az_enabled
  subnet_group_name          = aws_elasticache_subnet_group.elasticache_redis_subnetgroup.id
  # security_group_ids         = local.create_security_group ? concat(local.associated_security_group_ids, [module.aws_security_group.id]) : local.associated_security_group_ids
  security_group_ids = [aws_security_group.elasticache_redis_sg[each.value.name].id]
  maintenance_window = each.value.maintenance_window
  # notification_topic_arn     = var.notification_topic_arn
  engine_version             = each.value.redis_engine_version
  at_rest_encryption_enabled = each.value.at_rest_encryption_enabled
  kms_key_id                 = each.value.at_rest_encryption_enabled ? data.aws_kms_key.kms_cmk_ebs.arn : null
  transit_encryption_enabled = each.value.in_transit_encryption_enabled || each.value.auth_token != null
  auth_token                 = each.value.in_transit_encryption_enabled ? each.value.auth_token : null
  # snapshot_name              = var.snapshot_name
  # snapshot_arns              = var.snapshot_arns
  # snapshot_window            = var.snapshot_window
  # snapshot_retention_limit   = var.snapshot_retention_limit
  # final_snapshot_identifier  = var.final_snapshot_identifier
  apply_immediately = each.value.apply_change_immediately

  tags = {
    "Name" = each.value.name
  }
}
