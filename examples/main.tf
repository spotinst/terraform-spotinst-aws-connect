module "spotinst-aws-connect" {
    source = "spotinst/aws-connect/spotinst"

    #Name for the Spot account. The account name must contain at least one character that is a-z or A-Z
    name = "your-account-name"
    spotinst_token="your-token"

    #Policy File (Optional) File with policy to attach to role
    #    policy_file = templatefile(minimal-spot-iam-policy.json.tftpl", {
    #        region     = "us-east-1"
    #        account_id = "123456789" })
}

output "spot_account_id" {
    value = module.spotinst-aws-connect.spot_account_id
}
