# -------------------------
# Resource Group
# -------------------------
module "resource_group" {
  source                = "./modules/resource_group"
  create_resource_group = var.create_resource_group
  resource_group_name   = var.resource_group_name
  location              = var.location
  subscription_id       = var.subscription_id
}

locals {
  rg_name   = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
  rg_loc    = coalesce(module.resource_group.location, var.location)
}

# Outputs del módulo para usarlos globalmente
/*
* coalesce devuelve el primer valor no null. 
* Esto permite usar el Resource Group del módulo si existe, o el de dev.tfvars si no.
# */
output "resource_group_name" {
  value = local.rg_name
}

output "location" {
  value = local.rg_loc
}



# Outputs del módulo para usarlos globalmente
/*
* coalesce devuelve el primer valor no null. 
* Esto permite usar el Resource Group del módulo si existe, o el de dev.tfvars si no.
# */
# output "resource_group_name" {
#   value = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
# }

# output "location" {
#   value = coalesce(module.resource_group.location, var.location)
# }


# -------------------------
# Storage Accounts
# -------------------------
module "storage_account" {
  source                = "./modules/storage_account"
  create_storage_account = var.create_storage_account
  resource_group_name   = local.rg_name
  location              = local.rg_loc
  storage_accounts      = var.storage_accounts
}

# -------------------------
# Front Door (antes CDN)
# -------------------------
module "frontdoor" {
  source              = "./modules/frontdoor"
  create_cdn          = var.create_cdn
  cdn_name            = var.cdn_name               # nombre del perfil
  //name                = var.cdn_name               # nombre del perfil
  //sku_name            = var.cdn_sku                # nuevo: Standard_AzureFrontDoor o Premium_AzureFrontDoor
  resource_group_name = local.rg_name
  location            = local.rg_loc
  origin_hostname     = var.origin_hostname        # host de origen (ej: webapp.azurewebsites.net o storage)
  //tags                = var.tags
  security_headers    = var.security_headers
}
# -------------------------
# Service Bus
# -------------------------
module "service_bus" {
  source                     = "./modules/service_bus"
  create_service_bus         = var.create_service_bus
  service_bus_namespace_name = var.service_bus_namespace_name
  resource_group_name        = local.rg_name
  location                   = local.rg_loc
  sku                        = var.service_bus_sku
  service_bus_queues         = var.service_bus_queues
  service_bus_topics         = var.service_bus_topics
}

# -------------------------
# Key Vault
# -------------------------
module "key_vault" {
  source              = "./modules/key_vault"
  create_key_vault    = var.create_key_vault
  key_vault_name      = var.key_vault_name
  resource_group_name = local.rg_name
  location            = local.rg_loc
  secrets             = var.secrets
}

# -------------------------
# API Management
# -------------------------
module "api_management" {
  source              = "./modules/api_management"
  create_api_management = var.create_api_management
  api_management_name = var.api_management_name
  resource_group_name = local.rg_name
  location            = local.rg_loc
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
}

# -------------------------
# SignalR
# -------------------------
module "signalr_service" {
  source              = "./modules/signalr_service"
  signalr_name        = var.signalr_name
  create_signalr      = var.create_signalr
  //signalr_services    = var.signalr_services
  resource_group_name = local.rg_name
  location            = local.rg_loc
  tags                = var.tags
}


# -------------------------
# Cosmos DB
# -------------------------
module "cosmos_db" {
  source              = "./modules/cosmos_db"
  create_cosmos_db    = var.create_cosmos_db
  cosmosdb_name       = var.cosmosdb_name
  //cosmos_account_name = var.cosmos_account_name
  resource_group_name = local.rg_name
  location            = local.rg_loc
  cosmos_databases    = var.cosmos_databases
}


module "vnet" {
  source              = "./modules/vnet"
  create_vnet         = var.create_vnet
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  subnets             = var.subnets
  resource_group_name  = local.rg_name
  location             = local.rg_loc
  tags                = var.tags
}

module "log_analytics_workspace" {
  source              = "./modules/log_analytics_workspace"
  subscription_id     = var.subscription_id
  location            = var.location
  resource_group_name = var.resource_group_name
  reuse_existing_workspace = true
  tags                = var.tags
}

# -------------------------
# Azure Functions (App Service Plan / Consumption)
# -------------------------
module "azure_functions" {
  source              = "./modules/function_app/azure_functions"
  functions           = var.functions
  resource_group_name = local.rg_name
  location            = local.rg_loc
  action_group_ids    = var.action_group_ids
  subscription_id     = var.subscription_id
  workspace_id        = module.log_analytics_workspace.workspace_id
  depends_on          = [module.log_analytics_workspace]
}

# -------------------------
# Azure Functions Linux (Flex Consumption con azapi)
# -------------------------
module "azure_functions_linux" {
  source              = "./modules/function_app/azure_functions_linux"
  functions           = var.functions_linux
  resource_group_name = local.rg_name
  resource_group_id   = module.resource_group.resource_group_id
  location            = local.rg_loc
  subscription_id     = var.subscription_id
  workspace_id        = module.log_analytics_workspace.workspace_id
  depends_on          = [module.log_analytics_workspace]
}
