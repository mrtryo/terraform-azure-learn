resource "azurerm_lb" "loadbalancer" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-vm-lb-001"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "front-ip-001"
    subnet_id                     = azurerm_subnet.loadbalancer.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.vnet_subnet_cidr_loadbalancer, 4)
  }
}

resource "azurerm_lb_backend_address_pool" "bep001" {
  loadbalancer_id = azurerm_lb.loadbalancer.id
  name            = "bep-001"
}

resource "azurerm_network_interface_backend_address_pool_association" "bep001_association_server" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.server[count.index].id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bep001.id
}

resource "azurerm_lb_probe" "probe001" {
  loadbalancer_id = azurerm_lb.loadbalancer.id
  name            = "probe-001"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
}

resource "azurerm_lb_rule" "rule001" {
  loadbalancer_id                = azurerm_lb.loadbalancer.id
  name                           = "rule-001"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "front-ip-001"
  probe_id                       = azurerm_lb_probe.probe001.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bep001.id]
}
