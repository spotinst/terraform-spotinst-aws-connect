module "spotinst-aws-connect" {
    source = "spotinst/aws-connect/spotinst"

    #Name of the linked account in Spot (Optional) If none is provided will use account alias as the account name.
    name = "your-acct-name"
    spotinst_token="your-token"

    #Policy File (Optional) File with policy to attach to role
    #    policy_file = templatefile(minimal-spot-iam-policy.json.tftpl", {
    #        region     = "us-east-1"
    #        account_id = "123456789" })
}

output "spot_account_id" {
    value = module.spotinst-aws-connect.spot_account_id
}
