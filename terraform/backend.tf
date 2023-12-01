# terraform {
#   backend "azurerm" {
#     storage_account_name = "STORAGE_ACCOUNT_NAME"
#     container_name       = "terraform-state"
#     key                  = "terraform.tfstate"
#     access_key           = "STORAGE_ACCOUNT_ACCESS_KEY"
#   }
# }

# data "terraform_remote_state" "remote_state" {
#   backend = "azurerm"
#   config = {
#     storage_account_name = "STORAGE_ACCOUNT_NAME"
#     container_name       = "terraform-state"
#     key                  = "terraform.tfstate"
#     access_key           = "STORAGE_ACCOUNT_ACCESS_KEY"
#   }
# }
