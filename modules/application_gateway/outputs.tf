output "application_gateway_name" {
  value = azurerm_application_gateway.main.name
}

output "application_gateway_frontend_ip_configuration" {
  value = azurerm_application_gateway.main.frontend_ip_configuration
}
