resource "tls_private_key" "client" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "client" {
  content  = tls_private_key.client.private_key_pem
  filename = "./client.pem"
}

resource "azurerm_network_interface" "client" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-vm-client-001-nic01"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.client.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
}

resource "azurerm_linux_virtual_machine" "client" {
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  name                  = "${var.env}-${var.project}-${var.location_display}-vm-client-001"
  network_interface_ids = [azurerm_network_interface.client.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "${var.env}-${var.project}-${var.location_display}-vm-client-001-disk01"
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
    public_key = tls_private_key.client.public_key_openssh
  }
  disable_password_authentication = true

  depends_on = [
    azurerm_nat_gateway.gateway
  ]
}
