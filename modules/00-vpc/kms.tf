resource "aws_kms_key" "this" {
  for_each = var.kms_list


  description             = each.value.desc
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "this" {
  for_each = var.kms_list

  name          = "alias/${var.app_prefix}-lz-local-${each.key}"
  target_key_id = aws_kms_key.this[each.key].key_id
}