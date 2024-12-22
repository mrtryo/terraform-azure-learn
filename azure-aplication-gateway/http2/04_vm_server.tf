resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "server" {
  content  = tls_private_key.server.private_key_pem
  filename = "./server.pem"
}

resource "azurerm_network_interface" "server" {
  count               = 2
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-vm-server-${format("%03d", count.index + 1)}-nic01"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.server.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.vnet_subnet_cidr_server, 4 + count.index)
    primary                       = true
  }
}

resource "azurerm_linux_virtual_machine" "server" {
  count                 = 2
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  name                  = "${var.env}-${var.project}-${var.location_display}-vm-server-${format("%03d", count.index + 1)}"
  network_interface_ids = [azurerm_network_interface.server[count.index].id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "${var.env}-${var.project}-${var.location_display}-vm-server-${format("%03d", count.index + 1)}-disk01"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  admin_username = var.vm_username
  admin_ssh_key {
    username   = var.vm_username
    public_key = tls_private_key.server.public_key_openssh
  }
  disable_password_authentication = true

  depends_on = [
    azurerm_nat_gateway.natgateway
  ]
}

resource "azurerm_virtual_machine_extension" "server_nginx" {
  count                = 2
  name                 = "Nginx"
  virtual_machine_id   = azurerm_linux_virtual_machine.server[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "commandToExecute": "sudo apt-get update && sudo apt-get install nginx -y && echo \"$(hostname)\" > /var/www/html/index.html && sudo systemctl restart nginx"
 }
SETTINGS
}
