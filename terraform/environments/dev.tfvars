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


# Variables generals
environment          = "dev"
location             = "location_azure_resources"
subscription_id = "subscription_id_value" 
tenant_id = "tenant_id_value"
client_id = "client_id_value" #from your App Registration on Azure AD0
client_secret = "client_secret_value" #from your App Registration Secret on Azure AD

#Configuracion para las functions
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
    name            = "fn-ms-test-tf-2-v2-dev"
    plan_type       = "consumption"
    create          = false
    app_settings = [
      {
        name        = "kv-ServiceBusConnectionString"
        value       = "Endpoint=sb://...."
        slotSetting = false
      },
      {
        name        = "blobContainer"
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


functions_linux = [
  {
    name       = "fn-linux-consumption-tftest-dev"
    plan_type  = "FlexConsumption"
    create     = true
    app_settings = [
      { name = "SettingA", value = "ValueA", slotSetting = false },
      { name = "SettingB", value = "ValueB", slotSetting = false }
    ]
  }
]


#RG
resource_group_name  = "tf-resource-group-test-v1-dev-rg"

#Storage Account - Static Website
storage_account_name = "statesttfdev"

# Service Bus
service_bus_namespace_name = "sb-testtf-dev"
service_bus_queues = [
  {
    name = "queueue1"
    duplicate_detection_history_time_window = "PT10M"
    enable_dead_lettering_on_message_expiration = true
    #...
  },
  {
    name = "queueue2"
    duplicate_detection_history_time_window = "PT10M"
    enable_dead_lettering_on_message_expiration = true
    #...
  }
]

# Key Vault
key_vault_name = "kv-testtf-dev"


# API Management
api_management_name = "apim-testtf-dev"
publisher_name      = "YourCompanyName"
publisher_email     = "youremail@company.com"

# SignalR
signalr_name    = "test-tf-signalr"

#Cosmos DB
cosmosdb_name               = "testtf-cosmosdb-dev"
database_name               = "dev-database"
container_1_name            = "testtf-container1"
container_1_partition_key   = ["/rutaDeParticion1"]
container_1_throughput      = 400
container_2_name            = "testtf-container2"
container_2_partition_key   = ["/rutaDeParticion2"]
container_2_throughput      = 400


#Vnet
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


# cdn
cdn_name             = "cdn-tfportal-dev"
azurerm_cdn_endpoint = "test-tf-endpoint-dev"
static_site_url = "storagename.z13.web.core.windows.net"

cdn_rules = [
  {
    name = "Global2"
    condition = {
      operator     = "Equals"
      match_values = ["HTTPS"]
    }
    actions = [
      {
        header_action = "Append"
        header_name   = "X-Content-Type-Options"
        value         = "nosniff"
      },
      {
        header_action = "Append"
        header_name   = "Strict-Transport-Security"
        value         = "max-age=31536000; includeSubDomains"
      },
      {
        header_action = "Append"
        header_name   = "Referrer-Policy"
        value         = "strict-origin"
      }
    ]
  },
  {
    name = "EnforceHTTPS"
    conditions = [
      {
        operator     = "Equals"
        match_values = ["HTTP"]
      }
    ]
    actions = [
      {
        redirect_type = "Found" # 302
        protocol      = "HTTPS"
        hostname      = "" # Mantener vacío para usar el original
        path          = "" # Mantener vacío para usar el original
        query_string  = "" # Mantener vacío para usar el original
        fragment      = "" # Mantener vacío para usar el original
      }
    ]
  }
]
