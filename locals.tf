locals {
  cmd             = "${path.module}/scripts/spot_account_aws.py"
  account_id      = data.external.account.result["account_id"]
  organization_id = data.external.account.result["organization_id"]
  cloudProvider   = data.external.account.result["cloud_provider"]
  spotinst_token  = var.debug == true ? nonsensitive(var.spotinst_token) : var.spotinst_token
  name            = var.name == null ? data.aws_iam_account_alias.current.0.account_alias : var.name
  random          = random_id.random_string.hex
}

# Create a random string
resource "random_id" "random_string" {
  byte_length = 8
}