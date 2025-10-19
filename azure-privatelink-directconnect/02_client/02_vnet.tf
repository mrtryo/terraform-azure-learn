resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-vnet"
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "client" {
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "${var.env}-${var.project}-${var.location_display}-subnet-client"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vnet_subnet_cidr_clinet]
}

resource "azurerm_route_table" "rt_app" {
  name                = "${var.env}-${var.project}-${var.location_display}-udr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  route {
    name                   = "default-to-nva"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_private_endpoint.pe_dc.private_service_connection[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "app_assoc" {
  subnet_id      = azurerm_subnet.client.id
  route_table_id = azurerm_route_table.rt_app.id
}
