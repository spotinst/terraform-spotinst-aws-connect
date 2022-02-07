locals {
  cmd             = "${path.module}/scripts/spot-account-aws"
  account_id      = data.external.account.result["account_id"]
  organization_id = data.external.account.result["organization_id"]
  cloudProvider   = data.external.account.result["cloud_provider"]
  external_id     = data.external.external_id.result["external_id"]
  name            = var.name == null ? data.aws_iam_account_alias.current.account_alias : var.name
}