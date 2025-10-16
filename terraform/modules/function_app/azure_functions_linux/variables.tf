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

variable "subscription_id"     { type = string }

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


variable "allow_destroy" {
  description = "Permite destruir recursos. Debe estar en true solo para terraform destroy."
  type        = bool
  default     = false
}