variable "name" {
    type        = string
    default     = null
    description = "(OPTIONAL) Name for the Spot account. If none is provided will use the AWS Linked account display name for the Spot account name"
}
variable "spotinst_token" {
    type        = string
    description = "Spot API Token"
}
variable "debug" {
    type        = bool
    description = "Add flag to expose sensitive variables for troubleshooting"
    default     = false
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
variable "tags" {
    type        = map(string)
    default     = null
    description = "(OPTIONAL) Add tags to AWS resources"
}