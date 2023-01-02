output "spot_account_id" {
  description = "spot account_id"
  value       = data.external.account.result["account_id"]
}

output "cur_bucket_name" {
  value = aws_s3_bucket.cur_bucket.id
}

output "eco_role_arn" {
  value = aws_iam_role.eco.arn
}