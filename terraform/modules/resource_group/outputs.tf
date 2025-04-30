
output "resource_group_name" {
  value = length(azurerm_resource_group.rg) > 0 ? azurerm_resource_group.rg[0].name : var.resource_group_name
}

output "location" {
  value = length(azurerm_resource_group.rg) > 0 ? azurerm_resource_group.rg[0].location : var.location
}

# output "resource_group_id" {
#   value = length(azurerm_resource_group.rg) > 0 ? azurerm_resource_group.rg[0].id : var.resource_group_name
# }


output "resource_group_id" {
  value = length(azurerm_resource_group.rg) > 0 ? azurerm_resource_group.rg[0].id : "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
}