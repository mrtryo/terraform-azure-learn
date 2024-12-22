resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.env}-${var.project}-${var.location_display}-log-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}
