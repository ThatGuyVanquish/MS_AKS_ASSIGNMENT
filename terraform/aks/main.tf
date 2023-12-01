resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  identity {
    type = "SystemAssigned"
  }
  kubernetes_version = "1.27.7"

  dns_prefix = var.dns_prefix

  default_node_pool {
    name                  = "agentpool"
    vm_size               = "Standard_DS2_v2"
    node_count            = var.node_count
    max_pods              = 110
    os_disk_size_gb       = 128
    enable_auto_scaling   = true
    max_count             = 5
    min_count             = 2
    enable_node_public_ip = false
    os_sku                = "Ubuntu"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"

    service_cidr   = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"

    service_cidrs = ["10.0.0.0/16"]

    load_balancer_sku = "standard"
  }
}

resource "azurerm_role_assignment" "cluster_acr_role_assignment" {

  scope                = var.acr_id
  role_definition_name = "Owner"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id # AKS Service Principal ID
}

resource "azurerm_role_assignment" "agentpool_acr_role_assignment" {
  scope                = var.acr_id
  role_definition_name = "Owner"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id # Agentpool Principal ID
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
  client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_key)
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.cluster_ca_certificate)
}

resource "kubectl_manifest" "service_a_dep" {
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
  yaml_body  = file("${path.root}/../YAML/${var.service_a_dep}")
}

resource "kubectl_manifest" "service_a_svc" {
  depends_on = [kubectl_manifest.service_a_dep]
  yaml_body  = file("${path.root}/../YAML/${var.service_a_svc}")
}

resource "kubectl_manifest" "service_b_dep" {
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
  yaml_body  = file("${path.root}/../YAML/${var.service_b_dep}")
}

resource "kubectl_manifest" "service_b_svc" {
  depends_on = [kubectl_manifest.service_b_dep]
  yaml_body  = file("${path.root}/../YAML/${var.service_b_svc}")
}

resource "kubectl_manifest" "network_policy" {
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
  yaml_body  = file("${path.root}/../YAML/${var.network_policy_yaml}")
}

resource "kubectl_manifest" "ingress_config" {
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
  yaml_body  = file("${path.root}/../YAML/${var.ingress_config_yaml}")
}

# Set the new cluster as the k8s context
resource "null_resource" "k8s_context" {
  depends_on = [kubectl_manifest.service_a_svc]
  # Depending on service_a_svc as service_a should in theory take the longest to deploy, since it's service is deployed straight after it should be the last thing to be completed
  provisioner "local-exec" {
    command = <<EOT
      az aks get-credentials --resource-group ${var.rg_name} --name ${azurerm_kubernetes_cluster.aks_cluster.name}
      kubectl config use-context ${azurerm_kubernetes_cluster.aks_cluster.name}
    EOT
  }
}
