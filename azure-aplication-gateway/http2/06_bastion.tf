resource "azurerm_bastion_host" "my_bastion" {
  name                = "${var.env}-${var.project}-${var.location_display}-bastion-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_id  = azurerm_virtual_network.vnet.id
  sku                 = "Developer"
}
