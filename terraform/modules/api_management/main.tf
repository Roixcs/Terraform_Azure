resource "azurerm_api_management" "api_management" {
  count               = var.create_api_management ? 1 : 0
  name                = var.api_management_name
  location            = var.location
  resource_group_name  = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "Consumption_0" #"Standard_v2"

}