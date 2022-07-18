output "aws_account" {
    value = data.aws_caller_identity.current.account_id
}

output "spot_account_id" {
    value = jsondecode(restapi_object.account.create_response).response.items.0.id
}