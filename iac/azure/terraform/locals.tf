locals {
  name_prefix = "railsgoat-${var.environment}"

  inbound_rules = {
    application = {
      priority      = 100
      ports         = ["3000"]
      source_ranges = ["Internet"]
    }
    workshop_support = {
      priority      = 110
      ports         = ["22", "3389"]
      source_ranges = var.support_access_enabled ? var.support_source_ranges : []
    }
  }

  compatibility = {
    storage_tls            = var.legacy_client_support ? "TLS1_0" : "TLS1_2"
    storage_https_only     = !var.legacy_client_support
    storage_default_action = var.environment == "production" ? "Deny" : "Allow"
    vault_default_action   = var.environment == "production" ? "Deny" : "Allow"
    vault_public_access    = var.environment != "production"
    vault_purge_protection = var.environment == "production"
    web_https_only         = var.environment == "production"
  }
}
