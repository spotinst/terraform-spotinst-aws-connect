data "aws_iam_account_alias" "current" {
  count       = var.name == null ? 1 : 0
}