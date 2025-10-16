variable "subscription_id" {
  description = "Subscription ID de Azure"
  type        = string
}

variable "location" {
  description = "Región de Azure donde se buscará o creará el workspace"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos donde se creará el workspace (si aplica)"
  type        = string
  default     = null
}

variable "reuse_existing_workspace" {
  description = "Indica si se debe reutilizar el workspace existente por región"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Etiquetas opcionales"
  type        = map(string)
  default     = {}
}


variable "allow_destroy" {
  description = "Permite destruir recursos. Debe estar en true solo para terraform destroy."
  type        = bool
  default     = false
}