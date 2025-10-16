variable "create_cdn" {
  description = "Indica si se crea cdn"
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

variable "cdn_name" {
  type        = string
  description = "Nombre del CDN"
}


variable "storage_account_name" {
  description = "The name of the storage account for the static website"
  type        = string
}

variable "azurerm_cdn_endpoint" {
  description = "The name of the endpoint static website"
  type        = string
}

variable "static_site_url" {
  description = "The name of the endpoint static website"
  type        = string
}

variable "cdn_endpoints" {
  description = "Lista de configuraciones de los endpoints de CDN."
  type = map(object({
    name             = string
    origin_name      = string
    origin_host_name = string
    origin_http_port = optional(number, 80)
    origin_https_port = optional(number, 443)
  }))
}

variable "cdn_rules" {
  description = "Reglas dinámicas para el Rules Engine del CDN."
  type = list(object({
    name       = string
    conditions = list(object({
      operator     = string
      match_values = list(string)
    }))
    actions = list(object({
      header_action = optional(string)
      header_name   = optional(string)
      value         = optional(string)

      redirect_type = optional(string)
      protocol      = optional(string)
      hostname      = optional(string)
      path          = optional(string)
      query_string  = optional(string)
      fragment      = optional(string)
    }))
  }))
  default = []
}

variable "delivery_rules" {
  description = "Reglas de entrega para los endpoints del CDN."
  type        = list(object({
    name       = string
    conditions = optional(list(any))
    actions    = optional(list(any))
  }))
  default = []
}

variable "allow_destroy" {
  description = "Permite destruir recursos. Debe estar en true solo para terraform destroy."
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

