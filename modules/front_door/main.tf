# modules/front_door/main.tf

resource "azurerm_frontdoor" "main" {
  name                = "fd-it-oai-neusa-glob-001"
  resource_group_name = var.resource_group_name

  routing_rule {
    name               = "default-routing-rule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["default-frontend-endpoint"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "default-backend-pool"
    }
  }

  backend_pool_load_balancing {
    name = "default-load-balancing"
  }

  backend_pool_health_probe {
    name = "default-health-probe"
  }

  backend_pool {
    name = "default-backend-pool"
    backend {
      host_header = var.backend_host_header
      address     = var.backend_address
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "default-load-balancing"
    health_probe_name   = "default-health-probe"
  }

  frontend_endpoint {
    name                              = "default-frontend-endpoint"
    host_name                         = "${azurerm_frontdoor.main.name}.azurefd.net"
    custom_https_provisioning_enabled = false
  }
}

