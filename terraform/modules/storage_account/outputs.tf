output "primary_web_endpoint" {
  value = length(azurerm_storage_account.static_site) > 0 ? azurerm_storage_account.static_site[0].primary_web_host : null
}


# output "static_site_url" {
#   value = azurerm_storage_account.storage.primary_web_host
# }

# output "static_site_url" {
#   value = length(azurerm_storage_account.static_site.primary_web_host) ? azurerm_storage_account.static_site[0].primary_web_host : null
# }