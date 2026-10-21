resource "azurerm_log_analytics_workspace" "application" {
  name                = "${local.name_prefix}-logs"
  location            = azurerm_resource_group.application.location
  resource_group_name = azurerm_resource_group.application.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "web" {
  name                       = "application-diagnostics"
  target_resource_id         = azurerm_linux_web_app.application.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.application.id

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
