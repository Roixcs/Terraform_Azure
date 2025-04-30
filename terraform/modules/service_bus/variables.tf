variable "create_service_bus" {
  description = "Indica si se crea service_bus"
  type        = bool
  default     = false
}


variable "service_bus_namespace_name" {
  description = "Nombre del namespace para el Service Bus."
  type        = string
}

variable "service_bus_queue_name" {
  type = list(object({
    name                  = string
    duplicate_detection_history_time_window = optional(string, "PT10M")
    enable_dead_lettering_on_message_expiration = optional(bool, false)
  }))
  default = []
}

variable "location" {
  description = "Ubicación del recurso."
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos."
  type        = string
}
