output "postgresql_server_name" {
  value = azurerm_postgresql_server.main.name
}

output "postgresql_server_fqdn" {
  value = azurerm_postgresql_server.main.fqdn
}
