output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "cluster_host" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
}

output "cluster_client_key" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_key
}

output "cluster_client_certificate" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.cluster_ca_certificate
}