
# Function Plan (Flex Consumption)

resource "random_string" "storage_account_suffix" {
  for_each = { for func in var.functions : func.name => func if func.create }
  length   = 8
  special  = false
  upper    = false
}
resource "random_string" "plan_suffix_serverless" {
  for_each = { for func in var.functions : func.name => func if func.plan_type == "FlexConsumption" && func.create }
  length   = 4
  special  = false
  upper    = false
}

resource "azurerm_storage_account" "storage_account" {
  for_each = { for func in var.functions : func.name => func if func.create }

  name                     = "${replace(replace(substr(each.value.name, 0, 20), "-", ""), "fn", "")}${random_string.storage_account_suffix[each.key].result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_application_insights" "app_insights" {
  for_each = { for func in var.functions : func.name => func if func.create }

  name                = "ai-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

resource "azurerm_monitor_smart_detector_alert_rule" "failure_anomalies" {
  for_each             = { for func in var.functions : func.name => func if func.create }
  name                = "Failure Anomalies - ${each.value.name}-ai"
  resource_group_name = var.resource_group_name
  detector_type       = "FailureAnomaliesDetector"
  scope_resource_ids = toset([azurerm_application_insights.app_insights[each.value.name].id])

  severity  = "Sev0"
  frequency = "PT1M" # Evaluación cada 15 minutos
  description = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."

  action_group {
    ids = [] # Agregar IDs de grupos de acción si aplica
  }
  lifecycle {
    prevent_destroy = false # Permite que Terraform elimine este recurso con el destroy.
  }
}



resource "azapi_resource" "serverFarm" {
  for_each  = { for func in var.functions : func.name => func if func.create }
  type                      = "Microsoft.Web/serverfarms@2023-12-01"
  schema_validation_enabled = false
  location                  = var.location
  //name                      = each.value.name
  name                      = coalesce(each.value.plan_name, "asp-${each.value.name}")
  parent_id                 = var.resource_group_id
  body = {
    kind = "functionapp",
    sku = {
      tier = "FlexConsumption",
      name = "FC1"
    },
    properties = {
      reserved = true
    }
  }
}

resource "azapi_resource" "functionApps" {
  for_each             = { for func in var.functions : func.name => func if func.create }
  type                      = "Microsoft.Web/sites@2023-12-01"
  schema_validation_enabled = false
  location                  = var.location
  name                      = each.value.name
  parent_id                 = var.resource_group_id
  body = {
    kind = "functionapp,linux",
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      serverFarmId = azapi_resource.serverFarm[each.key].id
      functionAppConfig = {
        deployment = {
          storage = {
            type  = "blobContainer",
            value = azurerm_storage_account.storage_account[each.key].name
            authentication = {
              type = "SystemAssignedIdentity"
            }
          }
        },
        scaleAndConcurrency = {
          maximumInstanceCount = 40,
          instanceMemoryMB     = 2048,
        },
        # runtime = {
        #   name    = "dotnet-isolated",
        #   version = "8.0",
        # }
        runtime = {
          name    = try(each.value.runtime_name, "dotnet-isolated")
          version = try(each.value.runtime_version, "8.0")
        }
      },
      siteConfig = {
        appSettings = concat(
          [
            {
              name  = "AzureWebJobsStorage__accountName"
              value = azurerm_storage_account.storage_account[each.key].name
            },
            {
              name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
              value = azurerm_application_insights.app_insights[each.key].connection_string
            },
            {
              name  = "AzureWebJobsStorage"
              value = azurerm_storage_account.storage_account[each.key].primary_connection_string
            }
          ],
          each.value.app_settings
        )
        # appSettings = [
        #   {
        #     name  = "AzureWebJobsStorage__accountName",
        #     value = azurerm_storage_account.storage_account[each.key].name
        #   },
        #   {
        #     name  = "APPLICATIONINSIGHTS_CONNECTION_STRING",
        #     value = azurerm_application_insights.app_insights[each.key].connection_string
        #   }
        # ]
      }
    }
  }
    depends_on = [
      azapi_resource.serverFarm,
      azurerm_application_insights.app_insights,
      azurerm_storage_account.storage_account
    ]
}
