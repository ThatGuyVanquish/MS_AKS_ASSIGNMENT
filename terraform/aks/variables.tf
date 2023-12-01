
variable "aks_name" {
  type        = string
  description = "Name of the AKS cluster"
  default     = "nh-aks"
}

variable "dns_prefix" {
  type        = string
  description = "DRS Prefix of the AKS cluster"
  default     = "nh-aks-dns"
}

variable "username" {
  type        = string
  description = "Linux Login username"
  default     = "AzureAdmin"
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 2
}

variable "service_a_dep" {
  description = "The name of the YAML file for configuring the service-a deployment"
  default     = "btc-config.yaml"
}

variable "service_a_svc" {
  description = "The name of the YAML file for configuring the service-a svc"
  default     = "btc-service.yaml"
}

variable "service_b_dep" {
  description = "The name of the YAML file for configuring the service-b deployment"
  default     = "busybox-config.yaml"
}

variable "service_b_svc" {
  description = "The name of the YAML file for configuring the service-b svc"
  default     = "busybox-service.yaml"
}

variable "ingress_config_yaml" {
  description = "The name of the YAML file for configuring nginx ingress controller to route to /service-a and /service-b"
  default     = "ing.yaml"
}

variable "network_policy_yaml" {
  description = "The name of the YAML file for configuring the network policy prohibiting service-a and service-b from communicating"
  default     = "networkPolicy.yaml"
}

variable "rg_name" {
}

variable "rg_location" {
}

variable "acr_id" {
}
