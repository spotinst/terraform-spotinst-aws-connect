locals {
  cmd = "${path.module}/scripts/spot-account-aws"
  account_id = lookup(data.external.account.result,"account_id","Fail")
  external_id = chomp(data.local_file.external-id.content)
  name = var.name == null ? data.aws_iam_account_alias.current.account_alias : var.name
}

# Create a random string
resource "random_id" "role" {
  byte_length = 8
}