variable "resource_group_name" {
  type        = string
  description = "Nombre del Resource Group"
}

# variable "resource_group_id" {
#   type        = string
#   description = "ID del Resource Group"
# }

variable "location" {
  type        = string
  description = "Ubicación del Resource Group"
  validation {
    condition     = contains(["eastus", "eastus2", "westus"], var.location)
    error_message = "Location debe ser alguna de: eastus, eastus2, westus."
  }
}

variable "create_resource_group" {
  description = "Indica si se crea el Resource Group"
  type        = bool
  default     = false
}

variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
}

variable "allow_destroy" {
  description = "Permite destruir recursos. Debe estar en true solo para terraform destroy."
  type        = bool
  default     = false
}