resource "azurerm_application_gateway" "application_gateway" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-agw-001"

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"

    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration-01"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "frontend-port-01"
    port = 80
  }

  frontend_port {
    name = "frontend-port-02"
    port = 443
  }

  frontend_ip_configuration {
    name                          = "frontend-ip-configuration-01"
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.vnet_subnet_cidr_appgw, 4)
    subnet_id                     = azurerm_subnet.appgw.id
  }

  backend_address_pool {
    name = "backend-address-pool-01"
  }

  backend_http_settings {
    name                  = "backend-http-settings-01"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
  }

  http_listener {
    name                           = "http-listener-01"
    frontend_ip_configuration_name = "frontend-ip-configuration-01"
    frontend_port_name             = "frontend-port-01"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "request-routing-rule-01"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener-01"
    backend_address_pool_name  = "backend-address-pool-01"
    backend_http_settings_name = "backend-http-settings-01"
    priority                   = 1
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "backend_address_pool_association_server" {
  count                   = 1
  network_interface_id    = azurerm_network_interface.server[count.index].id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = one(azurerm_application_gateway.application_gateway.backend_address_pool).id
}
