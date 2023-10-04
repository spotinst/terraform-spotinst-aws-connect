# Connect AWS Account To Spot.io Terraform Module

## Introduction
The module will aid in automatically connecting an AWS Account to Spot via terraform.


### Pre-Reqs
* Spot.io organization admin [API token](https://docs.spot.io/administration/api/create-api-token).
* The Terraform CLI, version 0.14 or later.
* AWS Credentials configured for use with Terraform.

### Example
```hcl
module "spotinst-aws-connect" {
    source = "spotinst/aws-connect/spotinst"
    
    #Name for the Spot account. The account name must contain at least one character that is a-z or A-Z

    name = "your-acct-name"
    spotinst_token = "Redacted"

    #Policy File (Optional) File with policy to attach to the Spot role
    #policy_file = templatefile(minimal-spot-iam-policy.json.tftpl", {
    #   region     = "us-east-1"
    #   account_id = "123456789" })
}
```

### Run
This Terraform module will do the following:

On Apply:
* Create new Spot account within current Spot organization
* Retrieve unique External-ID returned by spot API
* Create AWS IAM Policy 
* Create AWS IAM Role with trust relationship
* Assign policy to IAM Role
* Provide IAM Role to newly created Spot Account
  

On Destroy:
* Remove all above resources including deleting the Spot account from the Spot platform

## Documentation

If you're new to [Spot](https://spot.io/) and want to get started, please checkout our [Getting Started](https://docs.spot.io/connect-your-cloud-provider/) guide, available on the [Spot Documentation](https://docs.spot.io/) website.

## Getting Help

We use GitHub issues for tracking bugs and feature requests. Please use these community resources for getting help:

- Ask a question on [Stack Overflow](https://stackoverflow.com/) and tag it with [terraform-spotinst](https://stackoverflow.com/questions/tagged/terraform-spotinst/).
- Join our [Spot](https://spot.io/) community on [Slack](http://slack.spot.io/).
- Open an issue.

## Community

- [Slack](http://slack.spot.io/)
- [Twitter](https://twitter.com/spot_hq/)

## Contributing

Please see the [contribution guidelines](CONTRIBUTING.md).
