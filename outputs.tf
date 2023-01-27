output "spot_account_id" {
  description = "spot account_id"
  value       = data.external.account.result["account_id"]
}

output "cur_bucket_name" {
  value = var.eco ? aws_s3_bucket.cur_bucket[0].id : ""
}

output "eco_role_arn" {
  value = var.eco ? aws_iam_role.eco[0].arn : ""
}