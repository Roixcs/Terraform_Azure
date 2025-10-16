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
  //for_each = { for db in var.cosmos_databases : db.name => db }
  for_each = var.create_cosmos_db ? { for db in var.cosmos_databases : db.name => db } : {}
  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb[0].name
  ///account_name        = var.create_cosmos_db ? azurerm_cosmosdb_account.cosmosdb[0].name : null
}

locals {
  cosmos_containers = flatten([
    for db in var.cosmos_databases : [
      for c in db.containers : {
        db_name            = db.name
        name               = c.name
        partition_key_path = c.partition_key_path
        throughput         = try(c.throughput, null)
      }
    ]
  ])
}


resource "azurerm_cosmosdb_sql_container" "this" {
  for_each = var.create_cosmos_db ? {
    for c in local.cosmos_containers :
    "${c.db_name}-${c.name}" => c
  } : {}

  name                = each.value.name
  partition_key_paths = [each.value.partition_key_path]
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb[0].name
  database_name       = azurerm_cosmosdb_sql_database.this[each.value.db_name].name

  throughput = each.value.throughput != null ? each.value.throughput : null
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