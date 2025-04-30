terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.15.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}
