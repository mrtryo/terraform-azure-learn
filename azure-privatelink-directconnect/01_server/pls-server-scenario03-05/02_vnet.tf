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

resource "azurerm_subnet" "server" {
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "${var.env}-${var.project}-${var.location_display}-subnet-server"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vnet_subnet_cidr_server]
}

resource "azurerm_subnet" "firewall" {
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "AzureFirewallSubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vnet_subnet_cidr_firewall]
}

resource "azurerm_subnet" "firewallmgmt" {
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "AzureFirewallManagementSubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vnet_subnet_cidr_firewallmngt]
}