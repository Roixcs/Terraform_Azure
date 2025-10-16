resource "azurerm_cdn_frontdoor_profile" "this" {
  count               = var.create_cdn ? 1 : 0
  name                = var.cdn_name
  resource_group_name = var.resource_group_name
  sku_name            = var.cdn_sku_name

}


resource "azurerm_cdn_frontdoor_endpoint" "this" {
  for_each = { for ep in var.frontdoor_endpoints : ep.name => ep }
  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
  enabled                  = true
}


resource "azurerm_cdn_frontdoor_origin_group" "this" {
   for_each = { for ep in var.frontdoor_endpoints : ep.name => ep }
  name                     = "${each.key}-og"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
  load_balancing {
    sample_size                  = 4
    successful_samples_required  = 3
  }

  session_affinity_enabled = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 5
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each                      = { for ep in var.frontdoor_endpoints : ep.name => ep }
  name                          = each.key
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.key].id
  host_name                     = each.value.origin_hostname
  certificate_name_check_enabled = true
  enabled                       = true
  http_port                     = 80
  https_port                    = 443
}

resource "azurerm_cdn_frontdoor_route" "this" {
  for_each = { for ep in var.frontdoor_endpoints : ep.name => ep }
  name                          = "${each.value.name}-Route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this[each.key].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.key].id
  cdn_frontdoor_origin_ids       = [azurerm_cdn_frontdoor_origin.this[0].id]
  patterns_to_match             = each.value.patterns_to_match
  supported_protocols           = ["Https"]
  https_redirect_enabled        = true
  forwarding_protocol           = "HttpsOnly"
  cdn_frontdoor_rule_set_ids    = try(each.value.rule_set_ids, [])
}


# 📌 Rules Engine para Rewrites y Headers de Seguridad
resource "azurerm_cdn_frontdoor_rule_set" "this" {
  count                     = var.create_cdn ? 1 : 0
  name                     = "RewiteRules" # substr(replace("${var.cdn_name}-Rules", "_", "-"), 4, 60)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
  //cdn_frontdoor_profile_id = try(azurerm_cdn_frontdoor_profile.this[0].id, null)

}

resource "azurerm_cdn_frontdoor_rule" "rewrite_index" {
  count               = var.create_cdn ? 1 : 0
  name          = "RewriteToIndex"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.this[0].id
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
  cdn_frontdoor_rule_set_id   = azurerm_cdn_frontdoor_rule_set.this[0].id

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