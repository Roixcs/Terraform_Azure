resource "azurerm_cdn_frontdoor_profile" "this" {
  count               = var.create_cdn ? 1 : 0
  name                = var.cdn_name
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  count               = var.create_cdn ? 1 : 0
  name                     = "${var.cdn_name}-ep"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
  enabled                  = true
  //tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  //count               = var.create_cdn ? 1 : 0
  name                     = "${var.cdn_name}-og"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
  load_balancing { // esto tambien lo solicitó
    sample_size            = 4
    successful_samples_required = 3
  }

  session_affinity_enabled = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 5
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  count                          = var.create_cdn ? 1 : 0
  name                           = "${var.cdn_name}-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.origin_hostname
  http_port                      = 80
  https_port                     = 443
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_route" "this" {
  count                         = var.create_cdn ? 1 : 0
  name                          = "${var.cdn_name}-route"
  cdn_frontdoor_endpoint_id      = azurerm_cdn_frontdoor_endpoint.this[0].id
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this.id
  cdn_frontdoor_origin_ids       = [azurerm_cdn_frontdoor_origin.this[0].id] # Added required attribute
  supported_protocols           = ["Https"]
  https_redirect_enabled        = true
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "HttpsOnly"
  link_to_default_domain        = true
  enabled                       = true

  cdn_frontdoor_rule_set_ids = [azurerm_cdn_frontdoor_rule_set.this.id]
}

# 📌 Rules Engine para Rewrites y Headers de Seguridad
resource "azurerm_cdn_frontdoor_rule_set" "this" {
  name                     = "${var.cdn_name}-rules"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
}

resource "azurerm_cdn_frontdoor_rule" "rewrite_index" {
  count               = var.create_cdn ? 1 : 0
  name          = "RewriteToIndex"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.this.id
  order         = 1

  conditions {
    request_uri_condition {
      operator = "Equal"
      match_values = ["/"]
    }
  }

  actions {
    url_rewrite_action {
      source_pattern = "/"
      destination    = "/index.html"
      preserve_unmatched_path = false
    }
  }
}

resource "azurerm_cdn_frontdoor_rule" "security_headers" {
  count          = var.create_cdn ? 1 : 0
  name          = "SecurityHeaders"
  order         = 2
  cdn_frontdoor_rule_set_id   = azurerm_cdn_frontdoor_rule_set.this.id

  actions {
      dynamic "response_header_action" {
        for_each = var.security_headers
        content {
          header_action = "Overwrite"
          header_name   = response_header_action.key
          value         = response_header_action.value
        }
      }
    }
}

# Asociar RuleSet al endpoint
# resource "azurerm_cdn_frontdoor_route_rule_set_association" "this" {
#   cdn_frontdoor_route_id   = azurerm_cdn_frontdoor_route.this.id
#   cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.this.id
# }