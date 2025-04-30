#Service Bus
resource "azurerm_servicebus_namespace" "servicebus" {
  count               = var.create_service_bus ? 1 : 0
  name                = var.service_bus_namespace_name
  location            = var.location
  resource_group_name  = var.resource_group_name
  sku                 = "Standard"
}

# Cola dentro del Service Bus
resource "azurerm_servicebus_queue" "queue" {
  count            = var.create_service_bus ? length(var.service_bus_queue_name) : 0
  name             = var.service_bus_queue_name[count.index].name
  duplicate_detection_history_time_window       = var.service_bus_queue_name[count.index].duplicate_detection_history_time_window
  namespace_id  = azurerm_servicebus_namespace.servicebus[0].id
}