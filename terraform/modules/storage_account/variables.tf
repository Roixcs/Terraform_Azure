# variable "create_storage_account" {
#   description = "Indica si se crea el Storage Account"
#   type        = bool
#   default     = false
# }

# variable "resource_group_name" {
#   type        = string
#   description = "Nombre del Resource Group"
# }

# variable "location" {
#   type        = string
#   description = "Ubicación del Resource Group"
# }

# variable "storage_account_name" {
#   type        = string
#   description = "Nombre del Storage Account"
# }


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

variable "storage_accounts" {
  description = "Lista de cuentas de Storage a crear"
  type = list(object({
    name                     = string
    account_tier             = string
    replication_type         = string
    kind                     = string           # Ej: "StorageV2"
    enable_static_website    = optional(bool)   # true si es Static Website
    index_document           = optional(string) # requerido si static website index.html
    error_document           = optional(string) # error.html si static website
    access_tier              = optional(string) # Hot / Cool
  }))
}


variable "allow_destroy" {
  description = "Permite destruir recursos. Debe estar en true solo para terraform destroy."
  type        = bool
  default     = false
}