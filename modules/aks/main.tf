resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-neusapre"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-neusapre"

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 2
  vnet_subnet_id        = var.subnet_id
}

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "aks-log-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
}

resource "azurerm_container_registry" "acr" {
  name                = "aksneusapre"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

