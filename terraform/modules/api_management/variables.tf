variable "create_api_management_name" {
  description = "Indica si se crea el APIM"
  type        = bool
  default     = false
}

variable "api_management_name" {
  description = "Nombre del API Management."
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

variable "publisher_name" {
  description = "Nombre del publicador de la API."
  type        = string
}

variable "publisher_email" {
  description = "Correo del publicador de la API."
  type        = string
}
