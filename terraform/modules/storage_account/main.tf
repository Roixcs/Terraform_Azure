
# Storage tipo Static Web Site
# resource "azurerm_storage_account" "static_site" {
#   count                    = var.create_storage_account ? 1 : 0 #controla si se crea o no
#   name                     = var.storage_account_name
#   resource_group_name      = var.resource_group_name
#   location                 = var.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   account_kind             = "StorageV2"

#   min_tls_version = "TLS1_2"

#   static_website {
#     index_document = "index.html"
#     error_404_document = "404.html"
#   }
# }



resource "azurerm_storage_account" "this" {
  //count                    = var.create_storage_account ? 1 : 0
  for_each                 = var.create_storage_account ? { for sa in var.storage_accounts : sa.name => sa } : {}

  name                     = each.value.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.replication_type
  account_kind             = each.value.kind

  min_tls_version           = "TLS1_2"
  //enable_https_traffic_only = false

  access_tier = try(each.value.access_tier, "Hot")

  dynamic "static_website" {
    for_each = each.value.enable_static_website ? [1] : []
    content {
      index_document     = try(each.value.index_document, "index.html")
      error_404_document = try(each.value.error_document, "404.html")
    }
  }

  //tags = var.tags
}

# # Static Website config (solo si enable_static_website = true)
# resource "azurerm_storage_account_static_website" "this" {
#   for_each = {
#     for sa in var.storage_accounts : sa.name => sa
#     if try(sa.enable_static_website, false)
#   }

#   storage_account_id = azurerm_storage_account.this[each.key].id
#   index_document     = try(each.value.index_document, "index.html")
#   error_404_document = try(each.value.error_document, "404.html")
# }
