# Terraform AWS Examples for Spot.io

## Introduction
The module will aid in automatically connecting an AWS Account to Spot via terraform.  This will leverage a `null_resource` calling a python script calling the Spot.io APIs to: create a Spot account within your Spot Organization, create a secure autogenerated externalId and add the ARN of the created IAM role to the Spot platform. 

### Pre-Reqs
* Spot.io organization admin [API token](https://docs.spot.io/administration/api/create-api-token). This is required to be added as an environment variable stored in `SPOTINST_TOKEN`.
* Python 3

###Example
```hcl
module "spotinst-aws-connect" {
    source = "spotinst/aws-connect/spotinst"

    #AWS Profile (Optional)
    #profile = ""

    #Name of the linked account in Spot (Optional) If none is provided will use AWS account alias as the account name.
    #name = "test-terraform"
  
    #Policy File (Optional) File with policy to attach to role
    #policy_file = example.json
}
```
### Run
This Terraform module will do the following:

On Apply:
* Create AWS IAM Policy 
* Create new Spot account within current Spot organization
* Retrieve unique auto-generated External-ID 
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
