output "acr_id" {
  value = azurerm_container_registry.acr_config.id
}

output "acr_link" {
  value = azurerm_container_registry.acr_config.login_server
}