data "aws_iam_account_alias" "current" {
  count       = var.name == null ? 1 : 0
}

# Retrieve the Spot Account ID
data "external" "account" {
  depends_on = [data.external.install_dependencies, null_resource.account]
  program = [
    local.cmd,
    "get",
    "--filter=name=${local.name}",
    "--token=${var.spotinst_token}"
  ]
}

data "external" "external_id" {
  depends_on = [data.external.install_dependencies, null_resource.account]
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

data "external" "install_dependencies" {
#  program = ["pip", "install", "-e", "${path.module}/scripts/"]
  program = ["${path.module}/scripts/setup.sh"]
}
