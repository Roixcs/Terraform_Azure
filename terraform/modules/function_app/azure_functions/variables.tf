# variable "functions" {
#   description = "Lista de funciones a crear con sus configuraciones"
#   type = list(object({
#     name                       = string
#     plan_type                  = string  # "consumption" o "basic"
#     create                     = bool    # Activa/desactiva la creación
#     app_settings = list(object({
#         name        = string
#         value       = string
#         slotSetting = optional(bool, false)
#     }))
#     plan_name                  = optional(string) # Nombre opcional del App Service Plan
#   }))
#   default = []
# }

# variable "functions" {
#   type = list(any)
# }


variable "functions" {
  description = "Lista de funciones a crear con sus configuraciones"
  type = list(object({
    name              = string
    plan_type         = string  # "consumption" o "basic"
    create            = bool
    plan_name         = optional(string)
    storage_name      = optional(string)
    app_insights_name = optional(string)
    app_settings = list(object({
      name        = string
      value       = string
      slotSetting = optional(bool, false)
    }))
  }))
  default = []
}

variable "action_group_ids" {
  description = "IDs de grupos de acción para alertas en Application Insights"
  type        = list(string)
  default     = []
}


variable "location" {
  type        = string
  description = "Ubicación"
}

variable "resource_group_name" {
  type        = string
  description = "Nombre del Resource Group"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Etiquetas para los recursos."
}

variable "workspace_id" {
  description = "ID del workspace de Log Analytics a reutilizar"
  type        = string
  default     = null
}

variable "create_workspace" {
  description = "Controla si se crea un nuevo workspace (true) o se usa uno existente (false)"
  type        = bool
  default     = true
}

variable "reuse_existing_workspace" {
  description = "Indica si se debe reutilizar el workspace existente o crear uno nuevo si no se encuentra"
  type        = bool
  default     = true
}
variable "subscription_id" {
  type = string
}

variable "allow_destroy" {
  description = "Permite destruir recursos. Debe estar en true solo para terraform destroy."
  type        = bool
  default     = false
}