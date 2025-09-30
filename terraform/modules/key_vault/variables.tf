variable "create_key_vault" {
  description = "Indica si se crea key_vault"
  type        = bool
  default     = false
}
variable "key_vault_name" {
  description = "Nombre del Key Vault."
  type        = string
}

variable "location" {
  description = "Ubicación del recurso."
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos."
  type        = string
}

# variable "tenant_id" {
#   description = "ID del tenant de Azure."
#   type        = string
# }

variable "secrets" {
  description = "Lista de secretos a crear en Key Vault"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
