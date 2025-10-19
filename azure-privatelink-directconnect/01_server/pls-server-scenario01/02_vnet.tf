resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-vnet"
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "pls" {
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "${var.env}-${var.project}-${var.location_display}-subnet-pls"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vnet_subnet_cidr_pls]
  # Private Link Service Direct Connectを使う場合は無効にする必要がある
  private_link_service_network_policies_enabled = false
}

resource "azurerm_subnet" "loadbalancer" {
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "${var.env}-${var.project}-${var.location_display}-subnet-loadbalancer"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vnet_subnet_cidr_loadbalancer]
}

resource "azurerm_subnet" "server" {
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "${var.env}-${var.project}-${var.location_display}-subnet-server"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vnet_subnet_cidr_server]
}
