variable "name" {
    type        = string
    default     = null
    description = "(OPTIONAL) Name for the Spot account. If none is provided will use the AWS Linked account display name for the Spot account name"
}
variable "spotinst_token" {
    type        = string
    description = "Spot API Token"
    sensitive   = true
}
variable "profile" {
    type        = string
    default     = null
    description = "(OPTIONAL) AWS profile name. Ex: default"
}
variable "policy_file" {
    type        = string
    default     = null
    description = "(OPTIONAL) Provide Custom IAM Policy File in JSON format"
}
variable "role_name" {
    type        = string
    default     = null
    description = "(OPTIONAL) Provide Custom IAM Role Name"
}
variable "policy_name" {
    type        = string
    default     = null
    description = "(OPTIONAL) Provide Custom IAM Policy Name"
}