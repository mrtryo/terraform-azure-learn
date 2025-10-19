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
  default = "pls"
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
  default = "192.168.0.0/24"
}

variable "vnet_subnet_cidr_pls" {
  type    = string
  default = "192.168.0.0/26"
}

variable "vnet_subnet_cidr_firewall" {
  type    = string
  default = "192.168.0.64/26"
}

variable "vnet_subnet_cidr_server" {
  type    = string
  default = "192.168.0.128/26"
}

variable "vnet_subnet_cidr_firewallmngt" {
  type    = string
  default = "192.168.0.192/26"
}

variable "vm_username" {
  type    = string
  default = "azpoc-user"
}
