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
  default = "agw"
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
  default = "192.168.101.0/25"
}

variable "vnet_subnet_cidr_clinet" {
  type    = string
  default = "192.168.101.0/28"
}

variable "vnet_subnet_cidr_appgw" {
  type    = string
  default = "192.168.101.16/28"
}

variable "vnet_subnet_cidr_server" {
  type    = string
  default = "192.168.101.32/28"
}

variable "vm_username" {
  type    = string
  default = "azpoc-user"
}

variable "filepath_self_signed_root_ca_certificate" {
  type    = string
  default = "./self-signed-certificates/root-ca-certificate/contoso.crt"
}
