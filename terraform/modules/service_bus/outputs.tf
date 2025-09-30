output "servicebus_namespace_id" {
  value = length(azurerm_servicebus_namespace.this) > 0 ? azurerm_servicebus_namespace.this[0].id : null
}
