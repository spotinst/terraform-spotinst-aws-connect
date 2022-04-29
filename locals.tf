locals {
  cmd             = "${path.module}/scripts/spot-account-aws"
  account_id      = data.external.account.result["account_id"]
  organization_id = data.external.account.result["organization_id"]
  cloudProvider   = data.external.account.result["cloud_provider"]
  external_id     = data.external.external_id.result["external_id"]
  name            = var.name == null ? data.aws_iam_account_alias.current.account_alias : var.name
  spotinst_token  = var.debug == true ? nonsensitive(var.spotinst_token) : var.spotinst_token
  random          = random_id.random_string.hex
}

# Create a random string
resource "random_id" "random_string" {
  byte_length = 8
}