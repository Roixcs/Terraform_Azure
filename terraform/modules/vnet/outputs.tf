output "vnet_name" {
  value = var.create_vnet ? azurerm_virtual_network.vnet[0].name : var.vnet_name
}

output "vnet_id" {
  description = "ID de la Virtual Network"
  value       = length(azurerm_virtual_network.vnet) > 0 ? azurerm_virtual_network.vnet[0].id : null
}

output "subnet_ids" {
  description = "IDs de las subnets"
  value       = {
    for key, subnet in azurerm_subnet.subnets : key => subnet.id
  }
}
