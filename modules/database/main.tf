# modules/database/main.tf

resource "azurerm_postgresql_server" "main" {
  name                = "neusa-postgre"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = "psqladmin"
  administrator_login_password = var.db_password

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 5120

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_postgresql_database" "main" {
  name                = "neusa_db"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.main.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_virtual_network_rule" "main" {
  name                                 = "postgresql-vnet-rule"
  resource_group_name                  = var.resource_group_name
  server_name                          = azurerm_postgresql_server.main.name
  subnet_id                            = var.subnet_id
  ignore_missing_vnet_service_endpoint = true
}



