output "servicebus_namespace_id" {
  value = length(azurerm_servicebus_namespace.servicebus) > 0 ? azurerm_servicebus_namespace.servicebus[0].id : null
}
