# modules/networking/main.tf

resource "azurerm_virtual_network" "api_management" {
  name                = "vnet-neusa-api-management"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "api_management" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.api_management.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "api_management" {
  name                = "nsg-neusa-api-management"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network" "aks" {
  name                = "aks-vnet-27965927"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network" "app_gateway" {
  name                = "vnet-app-gateway"
  address_space       = ["10.2.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "app_gateway" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.app_gateway.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_virtual_network" "gitlab_runner" {
  name                = "vnet-gitlab-runner"
  address_space       = ["10.3.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "gitlab_runner" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.gitlab_runner.name
  address_prefixes     = ["10.3.1.0/24"]
}

# Peering configurations
resource "azurerm_virtual_network_peering" "api_management_to_ingress_gateway" {
  name                      = "api-management-peering-ingress-gateway"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.api_management.name
  remote_virtual_network_id = azurerm_virtual_network.app_gateway.id
}

resource "azurerm_virtual_network_peering" "ingress_gateway_to_api_management" {
  name                      = "ingress-gateway-peering-api-management"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.app_gateway.name
  remote_virtual_network_id = azurerm_virtual_network.api_management.id
}

resource "azurerm_virtual_network_peering" "aks_to_app_gateway" {
  name                      = "gateway-peering-aks"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.aks.name
  remote_virtual_network_id = azurerm_virtual_network.app_gateway.id
}

resource "azurerm_virtual_network_peering" "app_gateway_to_aks" {
  name                      = "aks-peering-gateway"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.app_gateway.name
  remote_virtual_network_id = azurerm_virtual_network.aks.id
}



