output "function_app_names" {
  value = [for func in azurerm_windows_function_app.function_app : func.name]
}
output "storage_account_names" {
  value = [for account in values(azurerm_storage_account.storage_account) : account.name]
}


output "app_insights" {
  value = { for key, ai in azurerm_application_insights.app_insights : key => {
    name                 = ai.name
    instrumentation_key  = ai.instrumentation_key
    connection_string    = ai.connection_string
  } }
}



