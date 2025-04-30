variable "create_vnet" {
  description = "Indica si se crea Cosmos DB"
  type        = bool
  default     = false
}

variable "vnet_name" {
  description = "Nombre de la Virtual Network"
  type        = string
}

variable "address_space" {
  description = "Espacio de direcciones para la VNet"
  type        = list(string)
}

variable "subnets" {
  description = "Lista de subnets con configuraciones específicas"
  type = map(object({
    name             = string
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
  }))
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
}

variable "location" {
  description = "Ubicación para los recursos"
  type        = string
}

variable "tags" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}
