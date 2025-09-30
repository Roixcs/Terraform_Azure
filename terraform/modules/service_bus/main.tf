#Service Bus
# resource "azurerm_servicebus_namespace" "servicebus" {
#   count               = var.create_service_bus ? 1 : 0
#   name                = var.service_bus_namespace_name
#   location            = var.location
#   resource_group_name  = var.resource_group_name
#   sku                 = "Standard"
# }

# # Cola dentro del Service Bus
# resource "azurerm_servicebus_queue" "queue" {
#   count            = var.create_service_bus ? length(var.service_bus_queue_name) : 0
#   name             = var.service_bus_queue_name[count.index].name
#   duplicate_detection_history_time_window       = var.service_bus_queue_name[count.index].duplicate_detection_history_time_window
#   namespace_id  = azurerm_servicebus_namespace.servicebus[0].id
# }



resource "azurerm_servicebus_namespace" "this" {
  count               = var.create_service_bus ? 1 : 0
  name                = var.service_bus_namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
}

# Queues
resource "azurerm_servicebus_queue" "this" {
  for_each = {
    for q in var.queues : q.name => q
    if var.create_service_bus
  }

  name                = each.value.name
  namespace_id        = azurerm_servicebus_namespace.this[0].id
  max_size_in_megabytes = each.value.max_size_in_megabytes
  requires_duplicate_detection = each.value.requires_duplicate_detection
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  default_message_ttl = each.value.default_message_ttl
  lock_duration       = each.value.lock_duration
  dead_lettering_on_message_expiration = each.value.dead_lettering_on_message_expiration
}

# Topics
resource "azurerm_servicebus_topic" "this" {
  for_each = {
    for t in var.topics : t.name => t
    if var.create_service_bus && var.sku != "Basic"
  }

  name                = each.value.name
  namespace_id        = azurerm_servicebus_namespace.this[0].id
  max_size_in_megabytes = each.value.max_size_in_megabytes
  requires_duplicate_detection = each.value.requires_duplicate_detection
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  default_message_ttl = each.value.default_message_ttl
}

# Subscriptions
resource "azurerm_servicebus_subscription" "this" {
  for_each = {
    for t in var.topics : t.name => t.subscriptions...
    if var.create_service_bus && var.sku != "Basic"
  }

  name                = each.value.name
  topic_id            = azurerm_servicebus_topic.this[each.value.topic_name].id
  max_delivery_count  = each.value.max_delivery_count
  lock_duration       = each.value.lock_duration
  dead_lettering_on_message_expiration = each.value.dead_lettering_on_message_expiration
}