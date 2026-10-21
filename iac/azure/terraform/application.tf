resource "azurerm_service_plan" "application" {
  name                = "${local.name_prefix}-plan"
  resource_group_name = azurerm_resource_group.application.name
  location            = azurerm_resource_group.application.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "application" {
  name                                           = "${local.name_prefix}-web"
  resource_group_name                            = azurerm_resource_group.application.name
  location                                       = azurerm_resource_group.application.location
  service_plan_id                                = azurerm_service_plan.application.id
  https_only                                     = local.compatibility.web_https_only
  public_network_access_enabled                  = true
  ftp_publish_basic_authentication_enabled       = var.enable_legacy_release_pipeline
  webdeploy_publish_basic_authentication_enabled = var.enable_legacy_release_pipeline

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on           = false
    minimum_tls_version = var.application_minimum_tls_version
    ftps_state          = var.enable_legacy_release_pipeline ? "FtpsOnly" : "Disabled"

    application_stack {
      docker_image_name   = "owasp/railsgoat:latest"
      docker_registry_url = "https://index.docker.io"
    }
  }

  app_settings = {
    RAILS_ENV         = "production"
    DATABASE_HOST     = azurerm_postgresql_server.application.fqdn
    DATABASE_USER     = azurerm_postgresql_server.application.administrator_login
    DATABASE_PASSWORD = azurerm_key_vault_secret.bootstrap.value
    WEBSITES_PORT     = "3000"
  }
}

resource "azurerm_role_assignment" "application_operations" {
  scope                = azurerm_resource_group.application.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_web_app.application.identity[0].principal_id
}
