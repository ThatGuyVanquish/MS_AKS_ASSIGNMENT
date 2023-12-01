terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

provider "helm" {
  kubernetes {
    host                   = module.azure_aks.cluster_host
    client_key             = base64decode(module.azure_aks.cluster_client_key)
    client_certificate     = base64decode(module.azure_aks.cluster_client_certificate)
    cluster_ca_certificate = base64decode(module.azure_aks.cluster_ca_certificate)
  }
}

provider "kubectl" {
  config_path            = "~/.kube/config"
  config_context         = module.azure_aks.cluster_name
  host                   = module.azure_aks.cluster_host
  client_key             = base64decode(module.azure_aks.cluster_client_key)
  client_certificate     = base64decode(module.azure_aks.cluster_client_certificate)
  cluster_ca_certificate = base64decode(module.azure_aks.cluster_ca_certificate)
}
