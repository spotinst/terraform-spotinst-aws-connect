variable "name" {
    type        = string
    description = "Name for the Spot account. The account name must contain at least one character that is a-z or A-Z"
}
variable "spotinst_token" {
    type        = string
    description = "Spot API Token"
    sensitive   = true
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
variable "debug" {
    type        = bool
    description = "Add flag to expose sensitive variables for troubleshooting"
    default     = false
}