output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate
  sensitive = true
}
