
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.rg-name
  location = var.location
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

module "api_management" {
  source              = "./modules/api_management"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_id             = module.networking.vnet_api_management_id
  subnet_id           = module.networking.subnet_api_management_id
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_id             = module.networking.vnet_aks_id
  subnet_id           = module.networking.subnet_aks_id
}

module "gitlab_runner" {
  source                    = "./modules/gitlab_runner"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  vnet_id                   = module.networking.vnet_gitlab_runner_id
  subnet_id                 = module.networking.subnet_gitlab_runner_id
  admin_password            = var.admin_password
  runner_registration_token = var.runner_registration_token
  gitlab_url                = var.gitlab_url
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = module.networking.subnet_aks_id
}

module "database" {
  source              = "./modules/database"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = module.networking.subnet_aks_id
  db_password         = var.db_password
}

# module "application_gateway" {
#   source              = "./modules/application_gateway"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location
#   vnet_id             = module.networking.vnet_app_gateway_id
#   subnet_id           = module.networking.subnet_app_gateway_id
# }

# module "service_bus" {
#   source              = "./modules/service_bus"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location
#   subnet_id           = module.networking.subnet_aks_id
# }

# module "front_door" {
#   source              = "./modules/front_door"
#   resource_group_name = azurerm_resource_group.main.name
#   backend_host_header = module.application_gateway.application_gateway_frontend_ip_configuration[0].fqdn
#   backend_address     = module.application_gateway.application_gateway_frontend_ip_configuration[0].fqdn
# }

# module "openai" {
#   source              = "./modules/openai"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location
#   subnet_id           = module.networking.subnet_aks_id
# }
