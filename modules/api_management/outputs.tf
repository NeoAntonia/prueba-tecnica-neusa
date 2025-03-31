output "api_management_name" {
  value = azurerm_api_management.main.name
}

output "api_management_gateway_url" {
  value = azurerm_api_management.main.gateway_url
}
