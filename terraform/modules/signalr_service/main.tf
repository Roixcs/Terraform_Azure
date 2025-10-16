resource "azurerm_signalr_service" "signalr" {
  count               = var.create_signalr ? 1 : 0
  name                = var.signalr_name
  #name                = "${var.signalr_name}-${random_string.signalr_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku {
    name     = "Standard_S1" # "Standard_S1" "Free_F1"
    capacity = 1
  }
#   features {
#     flag   = "ServiceMode"
#     value  = "Default"
#   }

  tags = var.tags
}

resource "random_string" "signalr_suffix" {
  length  = 5
  special = false
  upper   = false
}
