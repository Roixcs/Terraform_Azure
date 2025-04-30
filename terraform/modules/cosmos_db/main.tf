# Cosmos DB Account
resource "azurerm_cosmosdb_account" "cosmosdb" {
  count               = var.create_cosmos_db ? 1 : 0
  name                = var.cosmosdb_name #"${var.cosmosdb_name}-${random_string.cosmosdb_suffix.result}"
  location            = var.location
  resource_group_name  = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless" # Serverless
  }

  tags = var.tags
}

# Cosmos DB Database
resource "azurerm_cosmosdb_sql_database" "database" {
  count               = var.create_cosmos_db ? 1 : 0
  name                = var.database_name #"${var.database_name}-${random_string.database_suffix.result}"
  resource_group_name = var.resource_group_name
  account_name        = length(azurerm_cosmosdb_account.cosmosdb) > 0 ? azurerm_cosmosdb_account.cosmosdb[0].name : null
  #account_name        =  var.create_cosmos_db ? azurerm_cosmosdb_account.cosmosdb[0].name : var.database_name
  #account_name        = azurerm_cosmosdb_account.cosmosdb.name
}

# Container 1
resource "azurerm_cosmosdb_sql_container" "container_1" {
  count               = var.create_cosmos_db ? 1 : 0
  name                = var.container_1_name
  resource_group_name = var.resource_group_name
  account_name        = length(azurerm_cosmosdb_account.cosmosdb) > 0 ? azurerm_cosmosdb_account.cosmosdb[0].name : null
  #account_name        =  var.create_cosmos_db ? azurerm_cosmosdb_account.cosmosdb[0].name : var.database_name
  database_name       = length(azurerm_cosmosdb_sql_database.database) > 0 ? azurerm_cosmosdb_sql_database.database[0].name : var.database_name

  partition_key_paths = var.container_1_partition_key # Aquí el nombre correcto es partition_key_paths
  #partition_key_version = 2
}

# Container 2
resource "azurerm_cosmosdb_sql_container" "container_2" {
  count               = var.create_cosmos_db ? 1 : 0
  name                = var.container_2_name
  resource_group_name = var.resource_group_name
  account_name        = length(azurerm_cosmosdb_account.cosmosdb) > 0 ? azurerm_cosmosdb_account.cosmosdb[0].name : null
  #account_name        =  var.create_cosmos_db ? azurerm_cosmosdb_account.cosmosdb[0].name : var.database_name
  database_name       = length(azurerm_cosmosdb_sql_database.database) > 0 ? azurerm_cosmosdb_sql_database.database[0].name : var.database_name

  partition_key_paths = var.container_2_partition_key # Asegurando el formato correcto como arreglo
  #partition_key_version = 2
}

resource "random_string" "cosmosdb_suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "random_string" "database_suffix" {
  length  = 5
  special = false
  upper   = false
}
