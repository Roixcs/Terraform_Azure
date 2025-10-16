variable "create_cosmos_db" {
  description = "Indica si se crea Cosmos DB"
  type        = bool
  default     = false
}

variable "cosmosdb_name" {
  description = "Nombre de la cuenta de Cosmos DB"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group donde se creará Cosmos DB"
  type        = string
}

variable "location" {
  description = "Ubicación del recurso"
  type        = string
}

variable "cosmos_databases" {
  description = "Lista de bases de datos Cosmos y sus contenedores"
  type = list(object({
    name       = string
    throughput = optional(number) # shared throughput
    containers = list(object({
      name               = string
      partition_key_path = string
      throughput         = optional(number) # dedicated throughput
    }))
  }))
}


variable "allow_destroy" {
  description = "Permite destruir recursos. Debe estar en true solo para terraform destroy."
  type        = bool
  default     = false
}




# variable "cosmosdb_name" {
#   type        = string
#   description = "Nombre base para la cuenta de Cosmos DB"
# }

# variable "database_name" {
#   type        = string
#   description = "Nombre de la base de datos en Cosmos DB"
# }

# variable "container_1_name" {
#   type        = string
#   description = "Nombre del primer contenedor"
# }

# variable "container_1_partition_key" {
#   type    = list(string)
#   #default = ["/rutaDeParticion1"]
# }

# variable "container_1_throughput" {
#   type        = number
#   description = "Capacidad de procesamiento para el primer contenedor (opcional)"
#   #default     = null
# }

# variable "container_2_name" {
#   type        = string
#   description = "Nombre del segundo contenedor"
# }

# variable "container_2_partition_key" {
#   type    = list(string)
#   #default = ["/rutaDeParticion2"]
# }

# variable "container_2_throughput" {
#   type        = number
#   description = "Capacidad de procesamiento para el segundo contenedor (opcional)"
#   #default     = null
# }

# variable "location" {
#   type        = string
#   description = "Localización para los recursos"
# }

# variable "resource_group_name" {
#   type        = string
#   description = "Nombre del grupo de recursos"
# }

variable "tags" {
  type        = map(string)
  description = "Etiquetas para los recursos"
  default     = {}
}
