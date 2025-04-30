module "resource_group" {
  source              = "./modules/resource_group"
  create_resource_group = var.create_resource_group
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Outputs del módulo para usarlos globalmente
/*
* coalesce devuelve el primer valor no null. 
* Esto permite usar el Resource Group del módulo si existe, o el de dev.tfvars si no.
*/
output "resource_group_name" {
  value = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
}

output "location" {
  value = coalesce(module.resource_group.location, var.location)
}

module "storage_account" {
  source              = "./modules/storage_account"
  create_storage_account = var.create_storage_account
  resource_group_name  = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
  depends_on          = [module.resource_group]
  location             = coalesce(module.resource_group.location, var.location)
  storage_account_name = var.storage_account_name
}

module "cdn" {
  source              = "./modules/cdn"
  create_cdn          = var.create_cdn
  cdn_name            = var.cdn_name
  resource_group_name  = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
  depends_on          = [module.resource_group]
  location             = coalesce(module.resource_group.location, var.location)
  storage_account_name = var.storage_account_name
  azurerm_cdn_endpoint = var.azurerm_cdn_endpoint
  static_site_url      = module.storage_account.primary_web_endpoint
  cdn_endpoints        = var.cdn_endpoints
  
  # Configuración para las reglas de entrega del CDN
  delivery_rules       = var.delivery_rules

}


module "service_bus" {
  source                     = "./modules/service_bus"
  create_service_bus         = var.create_service_bus
  service_bus_namespace_name = var.service_bus_namespace_name
  service_bus_queue_name     = var.service_bus_queue_name
  resource_group_name        = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
  depends_on          = [module.resource_group]
  location                   = coalesce(module.resource_group.location, var.location)
}

module "key_vault" {
  source              = "./modules/key_vault"
  create_key_vault    = var.create_key_vault
  key_vault_name      = var.key_vault_name
  resource_group_name = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
  depends_on          = [module.resource_group]
  location            = coalesce(module.resource_group.location, var.location)
  tenant_id           = var.tenant_id
}

module "api_management" {
  source               = "./modules/api_management"
  create_api_management_name = var.create_api_management
  api_management_name  = var.api_management_name
  resource_group_name  = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
  depends_on          = [module.resource_group]
  location             = coalesce(module.resource_group.location, var.location)
  publisher_name       = var.publisher_name
  publisher_email      = var.publisher_email
}

module "signalr_service" {
  source              = "./modules/signalr_service"
  create_signalr      = var.create_signalr
  signalr_name        = var.signalr_name
  resource_group_name  = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
  depends_on          = [module.resource_group]
  location             = coalesce(module.resource_group.location, var.location)
  tags                = var.tags
}

module "cosmos_db" {
  source              = "./modules/cosmos_db"
  create_cosmos_db    = var.create_cosmos_db
  cosmosdb_name       = var.cosmosdb_name
  resource_group_name  = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
  depends_on          = [module.resource_group]
  location             = coalesce(module.resource_group.location, var.location)
  tags                = var.tags
  container_1_name    =  var.container_1_name
  container_1_partition_key = var.container_1_partition_key
  container_1_throughput = var.container_1_throughput
  container_2_name    = var.container_2_name
  container_2_partition_key = var.container_2_partition_key
  container_2_throughput = var.container_2_throughput
  database_name       = var.database_name
}


module "vnet" {
  source              = "./modules/vnet"
  create_vnet         = var.create_vnet
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  subnets             = var.subnets
  resource_group_name  = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
  depends_on          = [module.resource_group]
  location             = coalesce(module.resource_group.location, var.location)
  tags                = var.tags
}

#New version for Azure Functions dynamic creation
module "azure_functions" {
  source                = "./modules/function_app/azure_functions"
  functions             = var.functions
  location              = var.location
  resource_group_name   = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
  depends_on            = [module.resource_group]
}

module "azure_functions_linux" {
  source                = "./modules/function_app/azure_functions_linux"
  functions             = var.functions_linux
  location              = var.location
  resource_group_name   = coalesce(module.resource_group.resource_group_name, var.resource_group_name)
  depends_on            = [module.resource_group]
}
