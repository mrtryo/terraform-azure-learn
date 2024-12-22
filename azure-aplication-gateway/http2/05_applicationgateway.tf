# Public APPGWにする場合
# resource "azurerm_public_ip" "appgateway" {
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = var.location
#   name                = "${var.env}-${var.project}-${var.location_display}-pip-gateway"
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

resource "azurerm_application_gateway" "application_gateway" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-agw-001"

  # HTTP/2
  enable_http2 = false

  sku {
    # Public APPGWにする場合
    # name     = "Basic"
    # tier     = "Basic"
    
    # Private APPGWにする場合（SKUはStandard_v2が必要、お高い）
    name     = "Standard_v2"
    tier     = "Standard_v2"

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
    # Public APPGWにする場合
    # public_ip_address_id          = azurerm_public_ip.appgateway.id

    # Private APPGWにする場合（SKUはStandard_v2が必要、お高い）
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

  http_listener {
    name                           = "http-listener-02"
    frontend_ip_configuration_name = "frontend-ip-configuration-01"
    frontend_port_name             = "frontend-port-02"
    protocol                       = "Https"
    ssl_certificate_name           = "www.fabrikam.com"
  }

  ssl_certificate {
    name     = "www.fabrikam.com"
    password = "www.fabrikam.com"
    data     = filebase64("./self-signed-certificates/server-certificate/fabrikam.pfx")
  }

  request_routing_rule {
    name                       = "request-routing-rule-01"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener-01"
    backend_address_pool_name  = "backend-address-pool-01"
    backend_http_settings_name = "backend-http-settings-01"
    priority                   = 1
  }

  request_routing_rule {
    name                       = "request-routing-rule-02"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener-02"
    backend_address_pool_name  = "backend-address-pool-01"
    backend_http_settings_name = "backend-http-settings-01"
    priority                   = 2
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "backend_address_pool_association_server" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.server[count.index].id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = one(azurerm_application_gateway.application_gateway.backend_address_pool).id
}

resource "azurerm_monitor_diagnostic_setting" "application_gateway" {
  name                           = "${var.env}-${var.project}-${var.location_display}-agw-001"
  target_resource_id             = azurerm_application_gateway.application_gateway.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.log.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
  }
}
