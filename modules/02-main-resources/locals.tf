locals {
  adjusted_number_of_az = var.number_of_az <= length(data.aws_availability_zones.available.names) ? var.number_of_az : length(data.aws_availability_zones.available.names)
  lc_name_list          = slice(data.aws_availability_zones.available.names, 0, local.adjusted_number_of_az)
  general_prefix        = format("%s-%s-%s", var.master_prefix, var.env_prefix, var.app_prefix)
}
