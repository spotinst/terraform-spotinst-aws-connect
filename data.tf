data "aws_iam_account_alias" "current" {}

# Retrieve the Spot Account ID
data "external" "account" {
  depends_on = [null_resource.account]
  program = [
    local.cmd,
    "get",
    "--filter=name=${local.name}",
    "--token=${var.spotinst_token}"
  ]
}

data "external" "external_id" {
  depends_on = [null_resource.account]
  program = [
    local.cmd,
    "create-external-id",
    local.account_id,
    "--token=${var.spotinst_token}"
  ]
  query = {
    cloudProvider = local.cloudProvider
  }
}