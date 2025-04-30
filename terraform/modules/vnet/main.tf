resource "azurerm_virtual_network" "vnet" {
  count               = var.create_vnet ? 1 : 0
  name                = var.vnet_name
  location            = var.location
  resource_group_name  = var.resource_group_name
  address_space       = var.address_space
  tags = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = var.create_vnet ? var.subnets : {}
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  #virtual_network_name = length(azurerm_virtual_network.vnet) > 0 ? azurerm_virtual_network.vnet[0].name : null # azurerm_virtual_network.vnet.name
  #virtual_network_name = var.create_vnet ? azurerm_virtual_network.vnet[0].name : azurerm_virtual_network.vnet.name
  virtual_network_name = var.create_vnet ? azurerm_virtual_network.vnet[0].name : var.vnet_name
  address_prefixes     = each.value.address_prefixes
  depends_on            = [azurerm_virtual_network.vnet]

  # Si necesitas delegación o un servicio específico, puedes incluirlo aquí
  delegation {
    name = "exampleDelegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms" # Cambiar según el servicio
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  service_endpoints = each.value.service_endpoints
}
