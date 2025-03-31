resource "azurerm_api_management" "main" {
  name                = "neusa-api-management"
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = "neusa"
  publisher_email     = "admin@neusa.com"

  sku_name = "Developer_1"

  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.subnet_id
  }
}

resource "azurerm_log_analytics_workspace" "apim" {
  name                = "apim-log-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
}

resource "azurerm_monitor_diagnostic_setting" "apim" {
  name                       = "apim-diagnostic-setting"
  target_resource_id         = azurerm_api_management.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.apim.id

  log {
    category = "GatewayLogs"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}

