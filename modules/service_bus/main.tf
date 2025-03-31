# modules/service_bus/main.tf

resource "azurerm_servicebus_namespace" "main" {
  name                = "sbus-it-oai-neusa-glob-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  network_rule_set {
    default_action = "Deny"
    virtual_network_rule {
      subnet_id = var.subnet_id
    }
  }
}

resource "azurerm_servicebus_queue" "main" {
  name                = "neusa-queue"
  namespace_name      = azurerm_servicebus_namespace.main.name
  resource_group_name = var.resource_group_name

  enable_partitioning = true
}



