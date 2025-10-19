resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-${var.project}-${var.location_display}-rg"
  location = var.location
}
