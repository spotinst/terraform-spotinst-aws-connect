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
variable "role_description" {
  type        = string
  default     = "Role for Spot.io Elastigroup/Ocean Products"
  description = "(OPTIONAL) Provide Custom IAM Role description"
}
variable "policy_name" {
  type        = string
  default     = null
  description = "(OPTIONAL) Provide Custom IAM Policy Name"
}
variable "policy_description" {
  type        = string
  default     = "Spot by NetApp IAM policy to manage resources"
  description = "(OPTIONAL) Provide Custom IAM Policy description"
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
variable "eco" {
  type        = bool
  description = "Create CUR and IAM role for Eco with EG/Ocean role"
  default     = false
}
variable "eco_only" {
  type        = bool
  description = "Create Eco role only without creating EG/Ocean role and Spot Account"
  default     = false
#  validation {
#    condition = var.eco == true
#    error_message = "Must also have 'eco' variable set to true"
#  }
}
variable "eco_full" {
  type        = bool
  description = "Change the Eco Policy to full permission"
  default     = false
#  validation {
#    condition = anytrue([
#      var.eco == true,
#      var.eco_only == true
#    ])
#    error_message = "Must also have 'eco' variable or 'eco_only' set to true"
#  }
}
variable "bucket_name" {
  type        = string
  default     = null
  description = "(OPTIONAL) Provide Custom S3 bucket Name for ECO"
}
variable "eco_role_name" {
  type        = string
  default     = null
  description = "(OPTIONAL) Provide Custom IAM Role Name for ECO"
}
variable "eco_role_description" {
  type        = string
  default     = null
  description = "(OPTIONAL) Provide Custom IAM Role Description for ECO"
}
variable "eco_policy_name" {
  type        = string
  default     = null
  description = "(OPTIONAL) Provide Custom IAM Policy Name for ECO"
}
variable "eco_policy_description" {
  type        = string
  default     = null
  description = "(OPTIONAL) Provide Custom IAM Policy Description for ECO"
}
variable "eco_policy_file" {
  type        = string
  default     = null
  description = "(OPTIONAL) Provide Custom IAM Policy File in JSON format for ECO"
}