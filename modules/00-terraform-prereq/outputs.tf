output "tfstate_s3_bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}

output "tfstate_lock_dynamodb_name" {
  value = aws_dynamodb_table.terraform_state_lock.name
}
