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
  default = "ilb"
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
  default = "192.168.0.0/25"
}

variable "vnet_subnet_cidr_clinet" {
  type    = string
  default = "192.168.0.0/28"
}

variable "vnet_subnet_cidr_loadbalancer" {
  type    = string
  default = "192.168.0.16/28"
}

variable "vnet_subnet_cidr_server" {
  type    = string
  default = "192.168.0.32/28"
}

variable "loadbalancer_enable_floatingip" {
  type    = bool
  default = false
}

variable "vm_username" {
  type    = string
  default = "azpoc-user"
}
