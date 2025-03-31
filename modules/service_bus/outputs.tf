output "servicebus_namespace_name" {
  value = azurerm_servicebus_namespace.main.name
}

output "servicebus_queue_name" {
  value = azurerm_servicebus_queue.main.name
}
