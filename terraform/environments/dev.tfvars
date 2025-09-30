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
resource_group_name  = "tf-resource-group-test-v1-dev-rg"


# -------------------------
# Azure Functions (App Service / Consumption)
# -------------------------
functions = [
  {
    name            = "fn-ms-test-tf-v1-dev" #For example
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
  },
  {
    name            = "fn-ms-test-tf-asp-v2-dev" 
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
    name       = "fn-linux-consumption-tftest-dev"
    plan_type  = "FlexConsumption"
    create     = true
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

storage_account_name = [
  {
    name                  = "stappwebdev01"
    account_tier          = "Standard"
    replication_type      = "LRS"
    kind                  = "StorageV2"
    enable_static_website = true
    index_document        = "index.html"
    error_document        = "404.html"
  },
  {
    name                  = "stblobdev01"
    account_tier          = "Standard"
    replication_type      = "LRS"
    kind                  = "StorageV2"
    enable_static_website = false
    access_tier           = "Cool"
  }
]

# -------------------------
# Service Bus
# -------------------------
service_bus_namespace_name = "sb-testtf-dev"
sku                        = "Standard"
queues = [
  {
    name     = "orders-queue"
    max_size_in_megabytes = 2048
    requires_duplicate_detection = true
    duplicate_detection_history_time_window = "PT30M"
  },
  {
    name     = "logs-queue"
    max_size_in_megabytes = 1024
  }
]

topics = [
  {
    name     = "events-topic"
    subscriptions = [
      {
        name = "sub-analytics"
      },
      {
        name = "sub-monitoring"
        max_delivery_count = 20
      }
    ]
  }
]
# service_bus_queues = [
#   {
#     name = "queueue1"
#     duplicate_detection_history_time_window = "PT10M"
#     enable_dead_lettering_on_message_expiration = true
#     #...
#   },
#   {
#     name = "queueue2"
#     duplicate_detection_history_time_window = "PT10M"
#     enable_dead_lettering_on_message_expiration = true
#     #...
#   }
# ]




# -------------------------
# Key Vault
# -------------------------
key_vault_name = "kv-testtf-dev"
secrets = [
  { name = "DB_ConnectionString", value = "SuperSecret123!" },
  { name = "SB_ConnectionString",     value = "XYZ-ABC-987654" }
]


# -------------------------
# API Management
# -------------------------
api_management_name = "apim-testtf-dev"
publisher_name      = "YourCompanyName"
publisher_email     = "youremail@company.com"


# -------------------------
# SignalR
# -------------------------
signalr_name    = "test-tf-signalr"



# -------------------------
# Cosmos DB
# -------------------------
cosmosdb_name               = "testtf-cosmosdb-dev"
# database_name               = "dev-database"
# container_1_name            = "testtf-container1"
# container_1_partition_key   = ["/rutaDeParticion1"]
# container_1_throughput      = 400
# container_2_name            = "testtf-container2"
# container_2_partition_key   = ["/rutaDeParticion2"]
# container_2_throughput      = 400
databases = [
  {
    name       = "productsdb"
    throughput = 400
    containers = [
      {
        name               = "items"
        partition_key_path = "/id"
        throughput         = 400
      },
      {
        name               = "logs"
        partition_key_path = "/date"
      }
    ]
  },
  {
    name       = "usersdb"
    containers = [
      {
        name               = "profiles"
        partition_key_path = "/userid"
      }
    ]
  }
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
cdn_name             = "cdn-tfportal-dev"
azurerm_cdn_endpoint = "test-tf-endpoint-dev"
cdn_sku      = "Standard_AzureFrontDoor"
//static_site_url = "storagename.z13.web.core.windows.net"
origin_hostname = "storagename.z13.web.core.windows.net" # origen de tu static site
security_headers = {
  "Content-Security-Policy" = "default-src 'self'"
  "X-Frame-Options"         = "DENY"
  "X-Content-Type-Options"  = "nosniff"
  "Referrer-Policy"         = "strict-origin-when-cross-origin"
}

cdn_endpoints = {
  endpoint1 = {
    name             = "tf-test-cdn-endpoint-dev"
    origin_name      = "statesttfdev"
    origin_host_name = "storagename.z13.web.core.windows.net" # DNS name backend
    origin_http_port = 80
    origin_https_port = 443
  }
  endpoint2 = {
    name             = "tf-test-cdn-endpoint2-dev"
    origin_name      = "statesttfdev"
    origin_host_name = "storagename.z13.web.core.windows.net" # DNS name backend
    origin_http_port = 80
    origin_https_port = 443
  }
}


# -------------------------
# Tags globales
# -------------------------
tags = {
  environment = "dev"
  project     = "terraform-azure"
}



# cdn_rules = [
#   {
#     name = "Global2"
#     condition = {
#       operator     = "Equals"
#       match_values = ["HTTPS"]
#     }
#     actions = [
#       {
#         header_action = "Append"
#         header_name   = "X-Content-Type-Options"
#         value         = "nosniff"
#       },
#       {
#         header_action = "Append"
#         header_name   = "Strict-Transport-Security"
#         value         = "max-age=31536000; includeSubDomains"
#       },
#       {
#         header_action = "Append"
#         header_name   = "Referrer-Policy"
#         value         = "strict-origin"
#       }
#     ]
#   },
#   {
#     name = "EnforceHTTPS"
#     conditions = [
#       {
#         operator     = "Equals"
#         match_values = ["HTTP"]
#       }
#     ]
#     actions = [
#       {
#         redirect_type = "Found" # 302
#         protocol      = "HTTPS"
#         hostname      = "" # Mantener vacío para usar el original
#         path          = "" # Mantener vacío para usar el original
#         query_string  = "" # Mantener vacío para usar el original
#         fragment      = "" # Mantener vacío para usar el original
#       }
#     ]
#   }
# ]
