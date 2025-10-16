#Flag to create resource control
create_resource_group   = true
create_storage_account  = false
create_signalr          = false
create_api_management   = false
create_cosmos_db        = false
create_vnet             = false
create_key_vault        = false
create_cdn              = false
create_service_bus      = false


# -------------------------
# Valores globales
# -------------------------
environment          = "dev"
location             = "location_azure_resources"
subscription_id = "subscription_id_value" 
tenant_id = "tenant_id_value"
client_id = "client_id_value" #from your App Registration on Azure AD0
client_secret = "client_secret_value" #from your App Registration Secret on Azure AD

# -------------------------
# Resource Group
# -------------------------
resource_group_name  = "rg-test-tf-uat"


# -------------------------
# Azure Functions (App Service / Consumption)
# -------------------------
functions = [
  {
    name            = "fn-ms-tf-serverless-uat" #For example
    plan_type       = "consumption"
    create          = false #flag
    app_settings = [
      {
        name        = "kv-ServiceBusConnectionString" #For example
        value       = "Endpoint=sb://...."
        slotSetting = false
      },
      {
        name        = "blobContainer" #For example
        value       = "files"
        slotSetting = false
      }
    ]
    plan_name   = null
  },
  {
    name            = "fn-ms..." 
    plan_type       = "basic" # App Service plan, Tier basic
    create          = false
    app_settings = [
      {
        name        = "kv-ServiceBusConnectionString" #For example
        value       = "Endpoint=sb://...."
        slotSetting = false
      },
      {
        name        = "blobContainer" #For example
        value       = "files"
        slotSetting = false
      }
    ]
    plan_name       = "ASP-test-tf-dev" #Name of the App Service Plan, if you have it previously created
  }
]

action_group_ids = [] # puedes poner un grupo de acción real si quieres alertas activas


# -------------------------
# Azure Functions Linux (Flex Consumption con azapi)
# -------------------------
functions_linux = [
  {
    name       = "fn-test-tf-notification-uat"
    plan_type  = "FlexConsumption"
    create     = true
    runtime_name = "dotnet-isolated"
    runtime_version = "8.0"
    app_settings = [
      { name = "SettingA", value = "ValueA", slotSetting = false },
      { name = "SettingB", value = "ValueB", slotSetting = false }
    ]
  },
  {
    name       = "fn-test-tf-datalogging-uat"
    plan_type  = "FlexConsumption"
    create     = false
    runtime_name = "dotnet-isolated"
    runtime_version = "8.0"
    app_settings = [
      { name = "SettingA", value = "ValueA", slotSetting = false },
      { name = "SettingB", value = "ValueB", slotSetting = false }
    ]
  },
  {
    name       = "fn-test-tf-sync-uat"
    plan_type  = "FlexConsumption"
    create     = false
    runtime_name = "dotnet-isolated"
    runtime_version = "8.0"
    app_settings = [
      { name = "SettingA", value = "ValueA", slotSetting = false },
      { name = "SettingB", value = "ValueB", slotSetting = false }
    ]
  },
  {
    name       = "fn-test-tf-logs-uat"
    plan_type  = "FlexConsumption"
    create     = false
    runtime_name = "dotnet-isolated"
    runtime_version = "8.0"
    app_settings = [
      { name = "SettingA", value = "ValueA", slotSetting = false },
      { name = "SettingB", value = "ValueB", slotSetting = false }
    ]
  }
]

# -------------------------
# Storage Accounts
# -------------------------
//storage_account_name = "statesttfdev"

storage_accounts = [
  {
    name                  = "statesttfuat"
    account_tier          = "Standard"
    replication_type      = "LRS"
    kind                  = "StorageV2"
    enable_static_website = true
    index_document        = "index.html"
    error_document        = "404.html"
  }
  # ,
  # {
  #   name                  = "stblobdev01"
  #   account_tier          = "Standard"
  #   replication_type      = "LRS"
  #   kind                  = "StorageV2"
  #   enable_static_website = false
  #   access_tier           = "Cool"
  # }
]

# -------------------------
# Service Bus
# -------------------------
service_bus_namespace_name = "sb-test-tf-uat"
sku                        = "Standard"
service_bus_queues = [
  {
    name     = "notifications"
    max_size_in_megabytes = 2048
    requires_duplicate_detection = true
    duplicate_detection_history_time_window = "PT30M"
  },
  {
    name     = "logs-queue"
    max_size_in_megabytes = 1024
  }
]

service_bus_topics = [
  # {
  #   name     = "events-topic"
  #   subscriptions = [
  #     {
  #       name = "sub-analytics"
  #     },
  #     {
  #       name = "sub-monitoring"
  #       max_delivery_count = 20
  #     }
  #   ]
  # }
]


# -------------------------
# Key Vault
# -------------------------
key_vault_name = "kv-tf-uat"
create_secrets = false
secrets = [
  { name = "DB-ConnectionString", value = "SuperSecret123!" },
  { name = "SB-ConnectionString",     value = "XYZ-ABC-987654" }
]


# -------------------------
# API Management
# -------------------------
api_management_name = "apim-serverless-tf-uat"
publisher_name      = "concentrix"
publisher_email     = "luisa.rico1@concentrix.com"


# -------------------------
# SignalR
# -------------------------
signalr_name    = "signalr-test-tf-uat"



# -------------------------
# Cosmos DB
# -------------------------
cosmosdb_name  = "cdb-test-tf-uat"
cosmos_databases = [
  {
    name       = "test"
    throughput = 400
    containers = [
      {
        name               = "CategorySettings"
        partition_key_path = "/id"
        //throughput        = 400 #opcional por si se requiere particular
      },
      {
        name               = "ConfirmationLogs"
        partition_key_path = "/id"
      },
      {
        name               = "Countries"
        partition_key_path = "/id"

      },
      {
        name               = "HostnameCountries"
        partition_key_path = "/id"
      },
      {
        name               = "NotificationLogs"
        partition_key_path = "/id"
      },
      {
        name               = "Notifications"
        partition_key_path = "/id"
      },
      {
        name               = "ServiceSettings"
        partition_key_path = "/id"
      }
    ]
  }
  # ,
  # {
  #   name       = "usersdb"
  #   containers = [
  #     {
  #       name               = "profiles"
  #       partition_key_path = "/userid"
  #     }
  #   ]
  # }
]


# -------------------------
# VNet
# -------------------------
vnet_name      = "test-tf-vnet"
address_space  = ["10.180.24.0/23"] #Red para Vnet

subnets = {
  subnet1 = {
    name             = "subnet-frontend"
    address_prefixes = ["10.180.24.0/28"] #Red de la Subnet 1
    service_endpoints = []
  }
  subnet2 = {
    name             = "subnet-backend"
    address_prefixes = ["10.180.24.16/29"] #Red de la Subnet 2
    service_endpoints = []
  }
}

# -------------------------
# Front Door (antes CDN)
# -------------------------
cdn_name             = "cdn-frontdoor-lift-uat"
azurerm_cdn_endpoint = "banner-test-tf"
cdn_sku_name      = "Standard_AzureFrontDoor"
//static_site_url = "storagename.z13.web.core.windows.net"
origin_hostname = "statesttfdev.z13.web.core.windows.net" # origen de tu static site
security_headers = {
  "Content-Security-Policy" = "default-src 'self'"
  "X-Frame-Options"         = "DENY"
  "X-Content-Type-Options"  = "nosniff"
  "Referrer-Policy"         = "strict-origin-when-cross-origin"
}



# -------------------------
# Tags globales
# -------------------------
tags = {
  environment = "uat"
  project     = "terraform-azure"
}
