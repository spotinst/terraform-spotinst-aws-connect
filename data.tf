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

# Retrieve the ExternalID
data "local_file" "external-id" {
  depends_on = [null_resource.create_external_id]
  filename = "${path.module}/scripts/external_id.txt"
}