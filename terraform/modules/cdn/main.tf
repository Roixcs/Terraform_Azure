resource "azurerm_cdn_profile" "cdn" {
  count               = var.create_cdn ? 1 : 0
  name                = var.cdn_name
  resource_group_name  = var.resource_group_name
  location            = var.location
  sku                 = "Standard_Microsoft"

}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  for_each = var.create_cdn ? var.cdn_endpoints : {}
  #count               = var.create_cdn ? 1 : 0
  name                = "${each.value.name}-endpoint"
  #profile_name        = azurerm_cdn_profile.cdn.azurerm_cdn_profile
  #profile_name        = length(azurerm_cdn_profile.cdn) > 0 ? azurerm_cdn_profile.cdn[0].name : null
  profile_name        = azurerm_cdn_profile.cdn[0].name
  resource_group_name      = var.resource_group_name
  location            = var.location
  is_https_allowed    = true
  is_http_allowed     = false

  origin {
    name      = each.value.origin_name
    host_name = each.value.origin_host_name != null ? replace(each.value.origin_host_name, "/https?:\\/\\//", "") : null
    http_port = each.value.origin_http_port
    https_port = each.value.origin_https_port
  }

  # Se pasa el bloque completo de delivery_rule desde la variable
  #delivery_rule = var.delivery_rules
  

}



# Recurso para las reglas del Rules Engine
# resource "azurerm_cdn_endpoint_delivery_rule" "cdn_delivery_rules" {
#   for_each = { for rule in var.delivery_rules : rule.name => rule }

#   name             = each.key
#   order            = each.value.order
#   endpoint_name    = azurerm_cdn_endpoint.cdn_endpoint.name
#   profile_name     = var.cdn_profile_name
#   resource_group_name = var.resource_group_name

#   dynamic "conditions" {
#     for_each = each.value.conditions
#     content {
#       operator         = conditions.value.operator
#       match_values     = conditions.value.match_values
#       negate_condition = conditions.value.negate_condition
#       match_variable   = conditions.value.match_variable
#       transforms       = conditions.value.transforms
#     }
#   }

#   dynamic "actions" {
#     for_each = each.value.actions
#     content {
#       header_action = actions.value.header_action
#       header_name   = actions.value.header_name
#       value         = actions.value.value

#       redirect_type = actions.value.redirect_type
#       protocol      = actions.value.protocol
#       hostname      = actions.value.hostname
#       path          = actions.value.path
#       query_string  = actions.value.query_string
#       fragment      = actions.value.fragment
#     }
#   }
# }


