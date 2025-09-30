data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  count                       = var.create_key_vault ? 1 : 0
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  enable_rbac_authorization   = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
}

resource "azurerm_key_vault_secret" "this" {
  for_each = { for s in var.secrets : s.name => s }

  name         = each.value.name
  value        = each.value.value
  key_vault_id = azurerm_key_vault.this[0].id
}


# resource "azurerm_key_vault" "key_vault" {
#   count                       = var.create_key_vault ? 1 : 0
#   name                        = var.key_vault_name
#   location                    = var.location
#   resource_group_name         = var.resource_group_name
#   tenant_id                   = var.tenant_id
#   sku_name                    = "standard"
#   soft_delete_retention_days  = 7
#   purge_protection_enabled    = false
# }
