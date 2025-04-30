variable "create_cosmos_db" {
  description = "Indica si se crea Cosmos DB"
  type        = bool
  default     = false
}


variable "cosmosdb_name" {
  type        = string
  description = "Nombre base para la cuenta de Cosmos DB"
}

variable "database_name" {
  type        = string
  description = "Nombre de la base de datos en Cosmos DB"
}

variable "container_1_name" {
  type        = string
  description = "Nombre del primer contenedor"
}

variable "container_1_partition_key" {
  type    = list(string)
  #default = ["/rutaDeParticion1"]
}

variable "container_1_throughput" {
  type        = number
  description = "Capacidad de procesamiento para el primer contenedor (opcional)"
  #default     = null
}

variable "container_2_name" {
  type        = string
  description = "Nombre del segundo contenedor"
}

variable "container_2_partition_key" {
  type    = list(string)
  #default = ["/rutaDeParticion2"]
}

variable "container_2_throughput" {
  type        = number
  description = "Capacidad de procesamiento para el segundo contenedor (opcional)"
  #default     = null
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
