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