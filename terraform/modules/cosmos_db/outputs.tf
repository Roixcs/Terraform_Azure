# output "cosmosdb_endpoint" {
#   value =  length(azurerm_cosmosdb_account.cosmosdb ) > 0 ? azurerm_cosmosdb_account.cosmosdb[0].endpoint : null
# }

# output "cosmosdb_primary_key" {
#   value = length(azurerm_cosmosdb_account.cosmosdb) > 0 ? azurerm_cosmosdb_account.cosmosdb[0].primary_key : null
# }

# output "database_name" {
#   value = length(azurerm_cosmosdb_sql_database.database) > 0 ? azurerm_cosmosdb_sql_database.database[0].name : null
# }

# output "container_1_name" {
#   value = length(azurerm_cosmosdb_sql_container.container_1) > 0 ? azurerm_cosmosdb_sql_container.container_1[0].name : null
# }

# output "container_2_name" {
#   value = length(azurerm_cosmosdb_sql_container.container_2) > 0 ? azurerm_cosmosdb_sql_container.container_2[0].name : null
# }
