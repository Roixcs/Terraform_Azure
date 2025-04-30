
# Storage tipo Static Web Site
resource "azurerm_storage_account" "static_site" {
  count                    = var.create_storage_account ? 1 : 0 #controla si se crea o no
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }
}