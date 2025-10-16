variable "create_service_bus" {
  description = "Indica si se crea service_bus"
  type        = bool
  default     = false
}


variable "service_bus_namespace_name" {
  description = "Nombre del namespace para el Service Bus."
  type        = string
}

# variable "service_bus_queue_name" {
#   type = list(object({
#     name                  = string
#     duplicate_detection_history_time_window = optional(string, "PT10M")
#     enable_dead_lettering_on_message_expiration = optional(bool, false)
#   }))
#   default = []
# }

variable "location" {
  description = "Ubicación del recurso."
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos."
  type        = string
}

variable "sku" {
  type        = string
  description = "SKU del namespace (Basic, Standard, Premium)"
  default     = "Standard"
}

variable "service_bus_queues" {
  description = "Lista de colas a crear en el Service Bus"
  type = list(object({
    name                               = string
    max_size_in_megabytes              = optional(number, 1024)
    enable_partitioning                = optional(bool, true)
    requires_duplicate_detection       = optional(bool, false)
    duplicate_detection_history_time_window = optional(string, "PT10M")
    default_message_ttl                = optional(string, "P14D")
    lock_duration                      = optional(string, "PT1M")
    dead_lettering_on_message_expiration = optional(bool, true)
  }))
  default = []
}

variable "service_bus_topics" {
  description = "Lista de tópicos a crear (solo Standard/Premium)"
  type = list(object({
    name                               = string
    max_size_in_megabytes              = optional(number, 1024)
    enable_partitioning                = optional(bool, true)
    requires_duplicate_detection       = optional(bool, false)
    duplicate_detection_history_time_window = optional(string, "PT10M")
    default_message_ttl                = optional(string, "P14D")
    subscriptions = list(object({
      name                          = string
      max_delivery_count            = optional(number, 10)
      lock_duration                 = optional(string, "PT1M")
      dead_lettering_on_message_expiration = optional(bool, true)
    }))
  }))
  default = []
}

variable "allow_destroy" {
  description = "Permite destruir recursos. Debe estar en true solo para terraform destroy."
  type        = bool
  default     = false
}