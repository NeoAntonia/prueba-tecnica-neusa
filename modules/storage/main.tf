resource "azurerm_storage_account" "main" {
  name                     = "permneusadev"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["0.0.0.0/0"]
    virtual_network_subnet_ids = [var.subnet_id]
  }
}

resource "azurerm_storage_container" "main" {
  name                  = "neusa-container"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

