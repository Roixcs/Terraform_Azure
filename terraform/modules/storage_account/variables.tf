variable "create_storage_account" {
  description = "Indica si se crea el Storage Account"
  type        = bool
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "Nombre del Resource Group"
}

variable "location" {
  type        = string
  description = "Ubicación del Resource Group"
}

variable "storage_account_name" {
  type        = string
  description = "Nombre del Storage Account"
}
