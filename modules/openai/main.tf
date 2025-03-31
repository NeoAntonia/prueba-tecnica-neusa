resource "azurerm_cognitive_account" "openai" {
  name                = "permaidev"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"

  sku_name = "S0"

  custom_subdomain_name = "permaidev"

  network_acls {
    default_action = "Deny"
    virtual_network_rules {
      subnet_id = var.subnet_id
    }
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_cognitive_deployment" "example" {
  name                 = "gpt-35-turbo"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo"
    version = "0301"
  }

  scale {
    type = "Standard"
  }
}

