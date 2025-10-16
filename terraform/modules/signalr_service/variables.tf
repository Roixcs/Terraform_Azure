variable "create_signalr" {
  description = "Indica si se crea SignalR"
  type        = bool
  default     = false
}


variable "signalr_name" {
  type        = string
  description = "Nombre base para el SignalR Service"
}

variable "location" {
  type        = string
  description = "Localización para los recursos"
}

variable "resource_group_name" {
  type        = string
  description = "Nombre del grupo de recursos"
}

variable "tags" {
  type        = map(string)
  description = "Etiquetas para los recursos"
  default     = {}
}


variable "allow_destroy" {
  description = "Permite destruir recursos. Debe estar en true solo para terraform destroy."
  type        = bool
  default     = false
}