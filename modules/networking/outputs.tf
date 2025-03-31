output "vnet_api_management_id" {
  value = azurerm_virtual_network.api_management.id
}

output "subnet_api_management_id" {
  value = azurerm_subnet.api_management.id
}

output "vnet_aks_id" {
  value = azurerm_virtual_network.aks.id
}

output "subnet_aks_id" {
  value = azurerm_subnet.aks.id
}

output "vnet_app_gateway_id" {
  value = azurerm_virtual_network.app_gateway.id
}

output "subnet_app_gateway_id" {
  value = azurerm_subnet.app_gateway.id
}

output "vnet_gitlab_runner_id" {
  value = azurerm_virtual_network.gitlab_runner.id
}

output "subnet_gitlab_runner_id" {
  value = azurerm_subnet.gitlab_runner.id
}
