resource "azurerm_public_ip" "pip" {
  name                = "${var.env}-${var.project}-${var.location_display}-pip01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "afw" {
  name                = "${var.env}-${var.project}-${var.location_display}-afw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku_tier            = "Standard"
  sku_name            = "AZFW_VNet"
  threat_intel_mode   = "Alert"
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  firewall_policy_id = azurerm_firewall_policy.policy.id
}


resource "azurerm_firewall_policy" "policy" {
  name                = "${var.env}-${var.project}-${var.location_display}-afwp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  lifecycle {
    ignore_changes = [
      explicit_proxy
    ]
  }
}

# 明示的なProxyは現時点のTerraformに対応していないのでazapiで個別に設定する。
resource "azapi_update_resource" "fwpolicy_explicit_proxy" {
  resource_id = azurerm_firewall_policy.policy.id
  type        = "Microsoft.Network/firewallPolicies@2024-10-01"

  body = {
    properties = {
      explicitProxy = {
        enableExplicitProxy = true
        httpPort            = 9001
        httpsPort           = 9002
        enablePacFile       = false
      }
    }
  }

  lifecycle {
    replace_triggered_by = [azurerm_firewall_policy.policy.id]
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "rcg" {
  name               = "${var.env}-${var.project}-${var.location_display}-afwpnrcg"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 1000

  application_rule_collection {
    name     = "all-allow"
    priority = 100
    action   = "Allow"
    rule {
      name             = "all-allow"
      source_addresses = ["*"]

      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      destination_fqdns = ["*"]
    }
  }

  nat_rule_collection {
    name     = "webserver"
    priority = 101
    action   = "Dnat"
    rule {
      name                  = "webserver"
      source_addresses      = ["*"]
      destination_address   = azurerm_firewall.afw.ip_configuration[0].private_ip_address
      destination_ports     = ["10080"]
      protocols             = ["TCP"]
      translated_address    = azurerm_network_interface.server[0].private_ip_address
      translated_port       = 80
    }
  }

}
