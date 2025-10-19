data "azurerm_private_link_service" "pls" {
  name                = "${var.env}-pls-${var.location_display}-pls"
  resource_group_name = "${var.env}-pls-${var.location_display}-rg"
}

resource "azurerm_private_endpoint" "pe_dc" {
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  name                          = "${var.env}-${var.project}-${var.location_display}-pe-directconnect"
  subnet_id                     = azurerm_subnet.client.id
  custom_network_interface_name = "${var.env}-${var.project}-${var.location_display}-pe-directconnect-nic"
  private_service_connection {
    name                           = "${var.env}-${var.project}-${var.location_display}-pe-directconnect"
    private_connection_resource_id = data.azurerm_private_link_service.pls.id
    is_manual_connection           = false
  }

  depends_on = [
    azurerm_linux_virtual_machine.client
  ]
}
