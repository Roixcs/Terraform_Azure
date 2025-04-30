
variable "environment" {
  description = "Nombre del ambiente (dev, uat, prd)"
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "Nombre del Resource Group"
}

variable "storage_account_name" {
  type        = string
  description = "Nombre del Storage Account"
}

variable "location" {
  type        = string
  description = "Ubicación de los recursos en Azure"
}

variable "cdn_name" {
  type        = string
  description = "Nombre del CDN"
}

variable "azurerm_cdn_endpoint" {
  description = "The name of the endpoint static website"
  type        = string
}

variable "cdn_endpoints" {
  description = "Configuraciones dinámicas de los endpoints del CDN."
  type = map(object({
    name             = string
    origin_name      = string
    origin_host_name = string
    origin_http_port = optional(number, 80)
    origin_https_port = optional(number, 443)
  }))
  default = {}
}

variable "delivery_rules" {
  description = "Reglas dinámicas para la entrega del CDN."
  type = list(object({
    name       = string
    conditions = optional(list(any))
    actions    = optional(list(any))
  }))
  default = []
}

variable "static_site_url" {
  description = "The name of the endpoint static website"
  type        = string
}

variable "subscription_id" {
  description = "The id of subscription"
  type        = string
  sensitive = true
}

variable "tenant_id" {
  description = "The id of tenant in azure"
  type        = string
  sensitive = true
}

variable "client_id" {
  description = "The client_id sp"
  type        = string
  sensitive = true
}

variable "client_secret" {
  description = "The client_secret sp"
  type        = string
  sensitive = true
}

variable "api_management_name" {
  description = "Nombre del API Management."
  type        = string
}

variable "key_vault_name" {
  description = "Nombre del Key Vault."
  type        = string
}

variable "publisher_name" {
  description = "Nombre del publicador de la API."
  type        = string
}

variable "publisher_email" {
  description = "Correo del publicador de la API."
  type        = string
}

# variable "plan_name" {
#   description = "Nombre del App Service Plan."
#   type        = string
# }

variable "service_bus_queue_name" {
  description = "Nombre de la queue para el Service Bus."
  type        = string
}

variable "service_bus_namespace_name" {
  description = "Nombre del namespace para el Service Bus."
  type        = string
}

variable "signalr_name" {
  type        = string
  description = "Nombre base para el SignalR Service"
}

variable "cosmosdb_name" {
  type        = string
  description = "Nombre base para el Cosmos DB Account"
}

variable "tags" {
  type        = map(string)
  description = "Etiquetas para los recursos"
  default     = {}
}

variable "database_name" {
  type        = string
  description = "Nombre de la base de datos en Cosmos DB"
}

variable "container_1_name" {
  type        = string
  description = "Nombre del primer contenedor"
}

variable "container_1_partition_key" {
  type    = list(string)
}

variable "container_1_throughput" {
  type        = number
  description = "Capacidad de procesamiento para el primer contenedor (opcional)"
  #default     = null
}

variable "container_2_name" {
  type        = string
  description = "Nombre del segundo contenedor"
}

variable "container_2_partition_key" {
  type    = list(string)
}

variable "container_2_throughput" {
  type        = number
  description = "Capacidad de procesamiento para el segundo contenedor (opcional)"
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

variable "functions" {
  description = "Lista de funciones a crear con sus configuraciones"
  type = list(object({
    name                       = string
    plan_type                  = string  # "consumption" o "b1"
    create                     = bool    # Activa/desactiva la creación
    app_settings = list(object({
        name        = string
        value       = string
        slotSetting = optional(bool, false)
    }))
    plan_name                  = optional(string)
  }))
  default = []
}

variable "functions_linux" {
  description = "Lista de funciones Linux"
  type = list(object({
    name        = string
    plan_type   = string # "basic" o "consumption"
    plan_name   = optional(string)
    create      = bool
    app_settings = list(object({
      name        = string
      value       = string
      slotSetting = bool
    }))
  }))
}




## Controlar la creacion de los recursos
variable "create_resource_group" {
  description = "Indica si se crea el Resource Group"
  type        = bool
  default     = false
}

variable "create_storage_account" {
  description = "Indica si se crea el Storage Account"
  type        = bool
  default     = false
}

variable "create_signalr" {
  description = "Indica si se crea SignalR"
  type        = bool
  default     = false
}

variable "create_api_management" {
  description = "Indica si se crea API Management"
  type        = bool
  default     = false
}

variable "create_cosmos_db" {
  description = "Indica si se crea Cosmos DB"
  type        = bool
  default     = false
}


variable "create_vnet" {
  description = "Indica si se crea Cosmos DB"
  type        = bool
  default     = false
}


variable "create_key_vault" {
  description = "Indica si se crea key_vault"
  type        = bool
  default     = false
}

variable "create_cdn" {
  description = "Indica si se crea cdn"
  type        = bool
  default     = false
}

variable "create_service_bus" {
  description = "Indica si se crea service_bus"
  type        = bool
  default     = false
}


# variable "delivery_rules" {
#   description = "Lista de reglas para el Rules Engine del CDN"
#   type = list(object({
#     name       = string
#     order      = number
#     conditions = list(object({
#       operator         = string
#       match_values     = list(string)
#       negate_condition = optional(bool)
#       match_variable   = optional(string)
#       transforms       = optional(list(string))
#     }))
#     actions = list(object({
#       header_action = optional(string)
#       header_name   = optional(string)
#       value         = optional(string)

#       redirect_type = optional(string)
#       protocol      = optional(string)
#       hostname      = optional(string)
#       path          = optional(string)
#       query_string  = optional(string)
#       fragment      = optional(string)
#     }))
#   }))
#   default = []
# }