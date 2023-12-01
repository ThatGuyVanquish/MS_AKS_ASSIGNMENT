resource "azurerm_resource_group" "rg_config" {
  name     = var.resource_group_name
  location = var.location
}

resource "null_resource" "login_set_subscription" {
  provisioner "local-exec" {
    command = <<EOT
      az login
      az account set --subscription "${var.subscription_id}"
    EOT
  }
}

# AKS Module
module "azure_aks" {
  source                 = "./aks"
  rg_name                = azurerm_resource_group.rg_config.name
  rg_location            = azurerm_resource_group.rg_config.location
  acr_id                 = module.azure_acr.acr_id
}

# ACR Module
module "azure_acr" {
  source                 = "./acr"
  rg_name                = azurerm_resource_group.rg_config.name
  rg_location            = azurerm_resource_group.rg_config.location
}

# HELM Module
module "helm_config" {
  source = "./helm"
  rg_name = azurerm_resource_group.rg_config.name
  rg_location = azurerm_resource_group.rg_config.location
  cluster_name = module.azure_aks.cluster_name
}
