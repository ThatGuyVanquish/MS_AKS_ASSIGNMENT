variable "acr_name" {
  description = "Name of the Azure Container Registry"
  default     = "navehacr"
}

variable "image_name" {
  description = "Name for the Bitcoin value retriever app"
  default     = "btc-express"
}

# variable "storage_account_name" {
# }

# variable "storage_container_name" {
# }

# variable "storage_access_key" {
# }

variable "rg_name" {
}

variable "rg_location" {
}

