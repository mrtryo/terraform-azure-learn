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

resource "azurerm_nat_gateway" "gateway" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-gateway"
  sku_name            = "Standard"
}

resource "azurerm_public_ip" "gateway" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-pip-gateway"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "gateway" {
  nat_gateway_id       = azurerm_nat_gateway.gateway.id
  public_ip_address_id = azurerm_public_ip.gateway.id
}

resource "azurerm_subnet_nat_gateway_association" "gateway_client" {
  subnet_id      = azurerm_subnet.client.id
  nat_gateway_id = azurerm_nat_gateway.gateway.id
}

resource "azurerm_subnet_nat_gateway_association" "gateway_server" {
  subnet_id      = azurerm_subnet.server.id
  nat_gateway_id = azurerm_nat_gateway.gateway.id
}

resource "azurerm_network_security_group" "client" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-subnet-client-nsg"

  # Inbound
  security_rule {
    name                       = "AllowBastionInBound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "168.63.129.16"
    destination_address_prefix = var.vnet_subnet_cidr_clinet
  }
  security_rule {
    name                       = "DenyAllInBound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Outbound
  security_rule {
    name              = "AllowInternetOutBound"
    priority          = 101
    direction         = "Outbound"
    access            = "Allow"
    protocol          = "Tcp"
    source_port_range = "*"
    destination_port_ranges = [
      "80",
      "443"
    ]
    source_address_prefix      = var.vnet_subnet_cidr_clinet
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                       = "AllowLoadbalancerOutBound"
    priority                   = 102
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.vnet_subnet_cidr_clinet
    destination_address_prefix = var.vnet_subnet_cidr_loadbalancer
  }
  security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "client" {
  subnet_id                 = azurerm_subnet.client.id
  network_security_group_id = azurerm_network_security_group.client.id
}

resource "azurerm_network_security_group" "loadbalancer" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-subnet-loadbalancer-nsg"

  # Inbound
  security_rule {
    name                       = "DenyAllInBound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Outbound
  security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "loadbalancer" {
  subnet_id                 = azurerm_subnet.loadbalancer.id
  network_security_group_id = azurerm_network_security_group.loadbalancer.id
}

resource "azurerm_network_security_group" "server" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = "${var.env}-${var.project}-${var.location_display}-subnet-server-nsg"

  # Inbound
  security_rule {
    name                       = "AllowBastionInBound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "168.63.129.16"
    destination_address_prefix = var.vnet_subnet_cidr_server
  }
  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = var.vnet_subnet_cidr_server
  }
  security_rule {
    name                       = "AllowClientInBound"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.vnet_subnet_cidr_clinet
    destination_address_prefix = var.vnet_subnet_cidr_server
  }
  security_rule {
    name                       = "DenyAllInBound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Outbound
  security_rule {
    name              = "AllowInternetOutBound"
    priority          = 101
    direction         = "Outbound"
    access            = "Allow"
    protocol          = "Tcp"
    source_port_range = "*"
    destination_port_ranges = [
      "80",
      "443"
    ]
    source_address_prefix      = var.vnet_subnet_cidr_server
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "server" {
  subnet_id                 = azurerm_subnet.server.id
  network_security_group_id = azurerm_network_security_group.server.id
}
