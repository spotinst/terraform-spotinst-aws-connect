terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.70"
    }
    spotinst = {
      source  = "spotinst/spotinst"
      version = ">=1.142.0"
    }
  }
}
