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

resource "azurerm_cosmosdb_sql_database" "this" {
  for_each = { for db in var.databases : db.name => db }
  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb[0].name
}

resource "azurerm_cosmosdb_sql_container" "this" {
  for_each = {
    for db in var.databases : db.name => db.containers...
  }
  name                = each.value.name
  partition_key_paths = [each.value.partition_key_path]
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb[0].name
  database_name       = azurerm_cosmosdb_sql_database.this[each.value.db_name].name
  throughput          = each.value.throughput
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