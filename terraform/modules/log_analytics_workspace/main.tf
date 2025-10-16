locals {
  # Convierte el location (eastus, eastus2, etc.) en alias corto
  region_alias = lower(var.location) == "eastus2" ? "EUS2" : lower(var.location) == "eastus"  ? "EUS"  : upper(replace(var.location, "-", ""))

  default_workspace_name   = "DefaultWorkspace-${var.subscription_id}-${local.region_alias}"
  default_resource_group   = "DefaultResourceGroup-${local.region_alias}"
}

# 1️⃣ Busca si ya existe el workspace por suscripción y región
data "azurerm_log_analytics_workspace" "existing" {
  count               = var.reuse_existing_workspace ? 1 : 0
  name                = local.default_workspace_name
  resource_group_name = local.default_resource_group
}

# 2️⃣ Crea el workspace solo si no existe
resource "azurerm_log_analytics_workspace" "workspace" {
  count = var.reuse_existing_workspace && length(data.azurerm_log_analytics_workspace.existing) > 0 ? 0 : 1

  name                = local.default_workspace_name
  location            = var.location
  resource_group_name = local.default_resource_group
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags                = var.tags
}

# 3️⃣ Determina el ID del workspace (existente o creado)
locals {
  workspace_id = coalesce(
    try(data.azurerm_log_analytics_workspace.existing[0].id, null),
    try(azurerm_log_analytics_workspace.workspace[0].id, null)
  )
}
