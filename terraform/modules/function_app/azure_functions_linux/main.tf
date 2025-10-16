
###############################################################################
#  Azure Functions Linux (Flex Consumption) - Terraform Module
#  Compatible with azurerm >= 4.0 and azapi >= 1.15
#  Author: Roixcs
###############################################################################


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


#########################
# Randoms
#########################

resource "random_string" "storage_account_suffix" {
  for_each = { for func in var.functions : func.name => func if func.create }
  length   = 6
  special  = false
  upper    = false
}

#########################
# Storage Account
#########################

resource "azurerm_storage_account" "storage_account" {
  for_each = { for func in var.functions : func.name => func if func.create }

  name                     = lower(replace("st${substr(each.value.name, 0, 18)}${random_string.storage_account_suffix[each.key].result}", "-", ""))
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

#########################
# Deployment Container
#########################

resource "azurerm_storage_container" "function_deploy" {
  for_each              = { for func in var.functions : func.name => func if func.create }
  name                  = "app-package-${each.value.name}"
  storage_account_name  = azurerm_storage_account.storage_account[each.key].name
  container_access_type = "private"
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


#########################
# Application Insights
#########################

resource "azurerm_application_insights" "app_insights" {
  for_each             = { for func in var.functions : func.name => func if func.create }
  name                 = "ai-${each.value.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  application_type     = "web"
  //workspace_id = null
  //workspace_id        = length(azurerm_log_analytics_workspace.workspace) > 0 ? azurerm_log_analytics_workspace.workspace[0].id : var.workspace_id
  workspace_id = coalesce(
    try(data.azurerm_log_analytics_workspace.existing[0].id, null),
    try(azurerm_log_analytics_workspace.workspace[0].id, null)
  )

}

#########################
# App Service Plan (Flex Consumption)
#########################

resource "azapi_resource" "serverFarm" {
  for_each = { for func in var.functions : func.name => func if func.create }

  type                      = "Microsoft.Web/serverfarms@2023-12-01"
  schema_validation_enabled = false
  name                      = "asp-${each.value.name}"
  location                  = var.location
  parent_id                 = var.resource_group_id

  body = {
    kind = "functionapp"
    sku  = {
      name = "FC1"
      tier = "FlexConsumption"
    }
    properties = {
      reserved = true
    }
  }
}

#########################
# Function App (Linux Flex)
#########################

resource "azapi_resource" "functionApps" {
  for_each = { for func in var.functions : func.name => func if func.create }
  #for_each = { for func in var.functions : func.name => func }

  type                      = "Microsoft.Web/sites@2023-12-01"
  schema_validation_enabled = false
  location                  = var.location
  name                      = each.value.name
  parent_id                 = var.resource_group_id

  body = {
    kind = "functionapp,linux"
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      serverFarmId = azapi_resource.serverFarm[each.key].id
      functionAppConfig = {
        deployment = {
          storage = {
            type  = "blobContainer"

            # ⚠️ ARM espera la URL completa del contenedor, no el nombre
            value = "https://${azurerm_storage_account.storage_account[each.key].name}.blob.core.windows.net/${azurerm_storage_container.function_deploy[each.key].name}"

            storageAccountResourceId = try(azurerm_storage_account.storage_account[each.key].id, "")
            containerName            = try(azurerm_storage_container.function_deploy[each.key].name, "")

            authentication = {
              type                              = "StorageAccountConnectionString"
              storageAccountConnectionStringName = "DEPLOYMENT_STORAGE_CONNECTION_STRING"
            }
          }
        }

        runtime = {
          name    = "dotnet-isolated"
          version = "8.0"
        }

        scaleAndConcurrency = {
          maximumInstanceCount = 40
          instanceMemoryMB     = 2048
        }
      }


      # 🔹 Site Config and App Settings
      siteConfig = {
        appSettings = concat(
          [
            #{ name = "FUNCTIONS_WORKER_RUNTIME", value = "dotnet-isolated" },
            #{ name = "DOTNET_VERSION", value = "8.0" },
            {
              name  = "APPLICATIONINSIGHTS_CONNECTION_STRING",
              value = try(azurerm_application_insights.app_insights[each.key].connection_string, "")
            },
            {
              name  = "DEPLOYMENT_STORAGE_CONNECTION_STRING",
              value = try(azurerm_storage_account.storage_account[each.key].primary_connection_string, "")
            },
            {
              name  = "AzureWebJobsStorage",
              value = try(azurerm_storage_account.storage_account[each.key].primary_connection_string, "")
            }
          ],
          [
            for setting in each.value.app_settings : {
              name  = setting.name
              value = setting.value
            }
          ]
        )
      }
    }
  }

  depends_on = [
    azapi_resource.serverFarm,
    azurerm_storage_account.storage_account,
    azurerm_storage_container.function_deploy,
    azurerm_application_insights.app_insights
  ]
}

#########################
# Smart Detector Alert (optional)
#########################

resource "azurerm_monitor_smart_detector_alert_rule" "failure_anomalies" {
  for_each             = { for func in var.functions : func.name => func if func.create }
  name                = "Failure Anomalies - ${each.value.name}"
  resource_group_name = var.resource_group_name
  detector_type       = "FailureAnomaliesDetector"
  scope_resource_ids  = [azurerm_application_insights.app_insights[each.key].id]
  severity            = "Sev3"
  frequency           = "PT1M"
  description         = "Alerts when failure rates increase abnormally."
  action_group {
    ids = []
  }
}
