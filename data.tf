data "aws_iam_account_alias" "current" {}

data "aws_default_tags" "default_tags" {}

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
    cloud_provider = local.cloudProvider
  }
}

resource "time_sleep" "wait_05" {
  depends_on = [data.external.external_id]
  create_duration = "5s"
}


data "aws_ssm_parameter" "external-id" {
  depends_on = [time_sleep.wait_05]
  name = "Spot-External-ID"
}
