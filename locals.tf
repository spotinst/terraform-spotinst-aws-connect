locals {
  cmd             = "${path.module}/scripts/spot-account-aws"
  account_id      = data.external.account.result["account_id"]
  organization_id = data.external.account.result["organization_id"]
  external_id     = chomp(data.local_file.external-id.content)
  name            = var.name == null ? data.aws_iam_account_alias.current.account_alias : var.name
}