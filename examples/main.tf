module "spotinst-aws-connect" {
    source = "spotinst/aws-connect/spotinst"

    #Name of the linked account in Spot (Optional) If none is provided will use account alias as the account name.
    #name = "test-terraform"

    #Policy File (Optional) File with policy to attach to role
    #policy_file = example.json
}

output "spot_account_id" {
    value = module.spotinst-aws-connect.spot_account_id
}
