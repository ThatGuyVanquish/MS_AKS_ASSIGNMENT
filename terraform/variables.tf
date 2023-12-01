variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  default     = "nh-aks-rg"
}

variable "location" {
  description = "Location for Azure resources"
  default     = "Israel Central"
}

variable "subscription_id" {
  description = "Your Azure subscription ID"
  default     = ""
}

variable "tenant_id" {
  description = "Your Azure tenant ID"
  default     = ""
}

# variable "storage_account_name" {
#   type        = string
#   description = "Your Azure Storage account name"
#   default     = ""
# }

# variable "storage_container_name" {
#   type        = string
#   description = "The Azure Storage Container name to deploy"
#   default     = "terraform-state"
# }

# variable "storage_access_key" {
#   type        = string
#   description = "Your Azure Storage Account access key"
#   default     = ""
# }
