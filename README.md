# ARM-Terraform

Infrastructure as a Code for Azure Resource Manager.

# Update Log.
#16 / Dic / 2024
- Resource Group
- API Management
- CDN and EndPoint for Static Website.
- Cosmos DB and Containers
- Azure Functions (Serverless and App Service Plan)
- Key Vault
- Service Bus
- Signal R Service
- Storage Account (V2)
- Vnet and Subnets
#23 / Dic / 2024
- Add Failure alert rule, Azure Functions

# VErsions
hashicorp/azurerm  -> 4.1.0
hashicorp/random  -> 3.4


## Getting started

-> terraform init -reconfigure
-> terraform plan -var-file="environments/dev.tfvars"
-> terraform apply -var-file="environments/dev.tfvars"
-> terraform destroy -var-file="environments/dev.tfvars"



