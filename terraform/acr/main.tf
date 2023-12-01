resource "azurerm_container_registry" "acr_config" {
  name                = var.acr_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  sku                 = "Basic"
  admin_enabled       = true
  tags = {
    environment = "production"
  }
}

resource "null_resource" "image_upload" {
  depends_on = [azurerm_container_registry.acr_config]
  provisioner "local-exec" {
    command = <<EOT
      az acr login --name ${azurerm_container_registry.acr_config.name}
      acrServer=$(az acr show --name ${azurerm_container_registry.acr_config.name})
      az acr build -t ${var.image_name}:latest -r ${azurerm_container_registry.acr_config.name} ../BTC_express_app/
      EOT
  }
}
