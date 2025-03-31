output "front_door_id" {
  value = azurerm_frontdoor.main.id
}

output "front_door_frontend_endpoint" {
  value = azurerm_frontdoor.main.frontend_endpoint[0].host_name
}