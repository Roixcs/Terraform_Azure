#########################
# Setteo de variables locales para el WorkSpace de ls Insight
#########################

locals {
  # Normaliza región (por ejemplo eastus → EUS, eastus2 → EUS2)
  region_alias = lower(var.location) == "eastus2" ? "EUS2" : lower(var.location) == "eastus"  ? "EUS"  : upper(replace(var.location, "-", ""))

  # Nombre canónico del workspace
  default_workspace_name = "DefaultWorkspace-${var.subscription_id}-${local.region_alias}"
}

data "azurerm_log_analytics_workspace" "existing" {
  count               = var.reuse_existing_workspace ? 1 : 0
  name                = local.default_workspace_name
  resource_group_name = "DefaultResourceGroup-${local.region_alias}" # patrón usado por Azure
}



resource "azurerm_service_plan" "service_plan" {
  for_each = { for func in var.functions : func.name => func if func.plan_type == "basic" && func.create }
  #for_each = { for func in var.functions : func.name => func if func.plan_type == "basic" }  # sin filtro


  name                = coalesce(each.value.plan_name, "ASP-${replace(substr(each.value.name, 0, 24), "-", "")}-${random_string.plan_suffix_b1[each.key].result}")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "B1"
  os_type             = "Windows"
}

resource "azurerm_service_plan" "consumption_plan" {
  for_each = { for func in var.functions : func.name => func if func.plan_type == "consumption" && func.create }
  #for_each = { for func in var.functions : func.name => func if func.plan_type == "consumption" }

  //name                = "ASP-${replace(substr(each.value.name, 0, 24), "-", "")}-${random_string.plan_suffix_serverless[each.key].result}"
  name                = coalesce(each.value.plan_name,
                    "ASP-${replace(substr(each.value.name, 0, 24), "-", "")}-${random_string.plan_suffix_serverless[each.key].result}"
                  )
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Y1"
  os_type             = "Windows"
}

resource "azurerm_windows_function_app" "function_app" {
  for_each = { for func in var.functions : func.name => func if func.create }
  #for_each = { for func in var.functions : func.name => func }

  name                       = each.value.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  storage_account_name       = azurerm_storage_account.storage_account[each.key].name
  storage_account_access_key = azurerm_storage_account.storage_account[each.key].primary_access_key
  service_plan_id = each.value.plan_type == "basic" ? azurerm_service_plan.service_plan[each.key].id : azurerm_service_plan.consumption_plan[each.key].id

  site_config {
    always_on = each.value.plan_type == "basic"
    # application_stack {
    #   # Para runtime aislado no se usa versión aquí
    #   //dotnet_version = "v8"
      
    #   //use_dotnet_isolated_runtime = true
    # }   

  }

  identity {
    type = "SystemAssigned"
  }
  # app_settings = merge(
  #   local.default_app_settings,
  #   each.value.app_settings
  # )

  # Convertir lista de settings en el formato requerido
  #app_settings = { for setting in each.value.app_settings : setting.name => setting.value }
  app_settings = merge(
    {
      "FUNCTIONS_WORKER_RUNTIME" = "dotnet-isolated"
      "DOTNET_VERSION"           = "8.0"
      "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
      "APPINSIGHTS_INSTRUMENTATIONKEY" = try(azurerm_application_insights.app_insights[each.key].instrumentation_key, "")
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = try(azurerm_application_insights.app_insights[each.key].connection_string, "")
    },
    { for setting in each.value.app_settings : setting.name => setting.value }
  )

  tags = var.tags

}

resource "azurerm_storage_account" "storage_account" {
  for_each = { for func in var.functions : func.name => func if func.create }
  #for_each = { for func in var.functions : func.name => func }

  name                     = "${replace(replace(substr(each.value.name, 0, 20), "-", ""), "fn", "")}${random_string.storage_account_suffix[each.key].result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "random_string" "storage_account_suffix" {
  for_each = { for func in var.functions : func.name => func if func.create }
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "plan_suffix_b1" {
  for_each = { for func in var.functions : func.name => func if func.plan_type == "basic" && func.create }
  length   = 4
  special  = false
  upper    = false
}

resource "random_string" "plan_suffix_serverless" {
  for_each = { for func in var.functions : func.name => func if func.plan_type == "consumption" && func.create }
  length   = 4
  special  = false
  upper    = false
}

locals {
  default_app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}

#########################
# Log Analytics Workspace (compartido)
#########################

resource "azurerm_log_analytics_workspace" "workspace" {
  count               = var.reuse_existing_workspace && length(data.azurerm_log_analytics_workspace.existing) > 0 ? 0 : 1

  name                = local.default_workspace_name
  location            = var.location
  resource_group_name = "DefaultResourceGroup-${local.region_alias}"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_application_insights" "app_insights" {
  //for_each             = { for func in var.functions : func.name => func if func.create }
  for_each             = { for func in var.functions : func.name => func  }
  name                 = "${each.value.name}-ai"
  location             = var.location
  resource_group_name  = var.resource_group_name
  application_type     = "web"
  //workspace_id        = var.workspace_id != null ? var.workspace_id : null
  workspace_id = coalesce(
    try(data.azurerm_log_analytics_workspace.existing[0].id, null),
    try(azurerm_log_analytics_workspace.workspace[0].id, null)
  )

  tags = var.tags
}


resource "azurerm_monitor_smart_detector_alert_rule" "failure_anomalies" {
  for_each             = { for func in var.functions : func.name => func if func.create }
  #for_each             = { for func in var.functions : func.name => func }
  
  name                = "Failure Anomalies - ${each.value.name}"
  resource_group_name = var.resource_group_name
  detector_type       = "FailureAnomaliesDetector"
  scope_resource_ids = toset([azurerm_application_insights.app_insights[each.value.name].id])

  severity  = "Sev0"
  frequency = "PT1M" # Evaluación cada 15 minutos
  description = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."

  action_group {
    ids = try(var.action_group_ids, [])
  }
  lifecycle {
    prevent_destroy = false # Permite que Terraform destruya este recurso al eliminarlo.
  }
}
