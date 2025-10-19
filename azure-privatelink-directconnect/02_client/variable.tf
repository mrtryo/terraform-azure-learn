variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "env" {
  type    = string
  default = "azpoc"
}

variable "project" {
  type    = string
  default = "client"
}

variable "location" {
  type    = string
  default = "westus"
}

variable "location_display" {
  type    = string
  default = "usw"
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/25"
}

variable "vnet_subnet_cidr_clinet" {
  type    = string
  default = "10.0.0.0/28"
}

variable "vm_username" {
  type    = string
  default = "azpoc-user"
}
