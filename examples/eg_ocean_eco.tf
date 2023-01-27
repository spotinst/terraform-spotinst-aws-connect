provider "aws" {
  region = "us-east-1"
}

module "aws-connect" {
  source = "spotinst/aws-connect/spotinst"

  spotinst_token = "c09767fd287c6c0df90a4eeba2380c34e248cd02faee419f81ee7b7be795a52f"
  name = "terraform_test1"
  #Enable creation of ECO Resources
  eco = true
  #ECO in read-only mode, true is full permissions
  eco_full = false
}

output "spot_account_id" {
  value = module.aws-connect.spot_account_id
}
output "cur_bucket_name" {
  value = module.aws-connect.cur_bucket_name
}
output "eco_role_arn" {
  value = module.aws-connect.eco_role_arn
}