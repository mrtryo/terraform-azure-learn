resource "azurerm_private_link_service" "pls" {
  name                = "${var.env}-${var.project}-${var.location_display}-pls"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  destination_ip_address = azurerm_network_interface.server[0].private_ip_address # Server VMのIPアドレス（NGINXでサービスを提供する）

  auto_approval_subscription_ids = [var.subscription_id]
  visibility_subscription_ids    = [var.subscription_id]

  nat_ip_configuration {
    name               = "primary"
    private_ip_address = cidrhost(var.vnet_subnet_cidr_pls, 4) # ソースNAT用のIPアドレス
    private_ip_address_version = "IPv4"
    subnet_id                  = azurerm_subnet.pls.id
    primary                    = true
  }

  nat_ip_configuration {
    name               = "secondary"
    private_ip_address = cidrhost(var.vnet_subnet_cidr_pls, 5) # ソースNAT用のIPアドレス
    private_ip_address_version = "IPv4"
    subnet_id                  = azurerm_subnet.pls.id
    primary                    = false
  }
}
