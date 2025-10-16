output "name" {
  value = length(azurerm_cdn_profile.cdn) > 0 ? azurerm_cdn_profile.cdn[0].name : null
}

# output "cdn_endpoint_name" {
#   value = length(azurerm_cdn_endpoint.endpoint) > 0 ? azurerm_cdn_endpoint.endpoint[0].name : null
# }
