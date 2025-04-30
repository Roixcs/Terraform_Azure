variable "functions" {
  description = "Lista de Azure Functions a crear"
  type = list(object({
    name        = string
    plan_type   = string
    plan_name   = optional(string)
    create      = bool
    app_settings = list(object({
      name        = string
      value       = string
      slotSetting = bool
    }))
  }))
}

variable "location" {
  description = "Ubicación de los recursos"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group"
  type        = string
}

variable "tags" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}
