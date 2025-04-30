variable "functions" {
  description = "Lista de funciones a crear con sus configuraciones"
  type = list(object({
    name                       = string
    plan_type                  = string  # "consumption" o "basic"
    create                     = bool    # Activa/desactiva la creación
    app_settings = list(object({
        name        = string
        value       = string
        slotSetting = optional(bool, false)
    }))
    plan_name                  = optional(string) # Nombre opcional del App Service Plan
  }))
  default = []
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