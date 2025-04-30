resource "azurerm_service_plan" "service_plan" {
  for_each = { for func in var.functions : func.name => func if func.plan_type == "basic" && func.create }

  name                = coalesce(each.value.plan_name, "ASP-${replace(substr(each.value.name, 0, 24), "-", "")}-${random_string.plan_suffix_b1[each.key].result}")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "B1"
  os_type             = "Windows"
}

resource "azurerm_service_plan" "consumption_plan" {
  for_each = { for func in var.functions : func.name => func if func.plan_type == "consumption" && func.create }

  name                = "ASP-${replace(substr(each.value.name, 0, 24), "-", "")}-${random_string.plan_suffix_serverless[each.key].result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Y1"
  os_type             = "Windows"
}

resource "azurerm_windows_function_app" "function_app" {
  for_each = { for func in var.functions : func.name => func if func.create }

  name                       = each.value.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  storage_account_name       = azurerm_storage_account.storage_account[each.key].name
  storage_account_access_key = azurerm_storage_account.storage_account[each.key].primary_access_key
  service_plan_id = each.value.plan_type == "basic" ? azurerm_service_plan.service_plan[each.key].id : azurerm_service_plan.consumption_plan[each.key].id

  site_config {
    always_on = each.value.plan_type == "b1"
    application_stack {
      dotnet_version = "v7.0"
      use_dotnet_isolated_runtime = true
    }
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
      "APPINSIGHTS_INSTRUMENTATIONKEY" = try(azurerm_application_insights.app_insights[each.key].instrumentation_key, "")
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = try(azurerm_application_insights.app_insights[each.key].connection_string, "")
    },
    { for setting in each.value.app_settings : setting.name => setting.value }
  )

  tags = var.tags

  lifecycle {
    ignore_changes = [tags, app_settings]
  }

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

resource "azurerm_application_insights" "app_insights" {
  for_each             = { for func in var.functions : func.name => func if func.create }
  name                 = "${each.value.name}-ai"
  location             = var.location
  resource_group_name  = var.resource_group_name
  application_type     = "web"

  tags = var.tags
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
    prevent_destroy = false # Permite que Terraform destruya este recurso al eliminarlo.
  }
}
