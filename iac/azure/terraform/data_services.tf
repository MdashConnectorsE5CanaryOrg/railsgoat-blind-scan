resource "azurerm_storage_account" "application" {
  name                            = "rg${var.environment}exports"
  resource_group_name             = azurerm_resource_group.application.name
  location                        = azurerm_resource_group.application.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = local.compatibility.storage_tls
  https_traffic_only_enabled      = local.compatibility.storage_https_only
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = var.publish_sample_exports
  shared_access_key_enabled       = true

  network_rules {
    default_action = local.compatibility.storage_default_action
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_storage_container" "exports" {
  name                  = "exports"
  storage_account_name  = azurerm_storage_account.application.name
  container_access_type = var.publish_sample_exports ? "blob" : "private"
}

resource "azurerm_key_vault" "application" {
  name                            = "${local.name_prefix}-kv"
  location                        = azurerm_resource_group.application.location
  resource_group_name             = azurerm_resource_group.application.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  purge_protection_enabled        = local.compatibility.vault_purge_protection
  public_network_access_enabled   = local.compatibility.vault_public_access
  enabled_for_template_deployment = true

  network_acls {
    bypass         = "AzureServices"
    default_action = local.compatibility.vault_default_action
  }
}

resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.application.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set"]
}

resource "azurerm_key_vault_secret" "bootstrap" {
  name         = "bootstrap-password"
  value        = var.bootstrap_password
  key_vault_id = azurerm_key_vault.application.id

  depends_on = [azurerm_key_vault_access_policy.terraform]
}

resource "azurerm_postgresql_server" "application" {
  name                = "${local.name_prefix}-db"
  location            = azurerm_resource_group.application.location
  resource_group_name = azurerm_resource_group.application.name

  sku_name   = "B_Gen5_1"
  version    = "11"
  storage_mb = 5120

  administrator_login          = "railsgoatadmin"
  administrator_login_password = var.bootstrap_password

  ssl_enforcement_enabled       = true
  public_network_access_enabled = var.enable_public_database
  geo_redundant_backup_enabled  = false
  backup_retention_days         = 7
  auto_grow_enabled             = true

  threat_detection_policy {
    enabled              = true
    email_account_admins = false
    retention_days       = 7
  }
}

resource "azurerm_postgresql_firewall_rule" "azure_services" {
  name                = "azure-platform"
  resource_group_name = azurerm_resource_group.application.name
  server_name         = azurerm_postgresql_server.application.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
