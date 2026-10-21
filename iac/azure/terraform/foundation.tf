data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "application" {
  name     = "${local.name_prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "application" {
  name                = "${local.name_prefix}-vnet"
  address_space       = ["10.42.0.0/16"]
  location            = azurerm_resource_group.application.location
  resource_group_name = azurerm_resource_group.application.name
}

resource "azurerm_subnet" "application" {
  name                 = "application"
  resource_group_name  = azurerm_resource_group.application.name
  virtual_network_name = azurerm_virtual_network.application.name
  address_prefixes     = ["10.42.1.0/24"]
}

resource "azurerm_network_security_group" "application" {
  name                = "${local.name_prefix}-nsg"
  location            = azurerm_resource_group.application.location
  resource_group_name = azurerm_resource_group.application.name

  dynamic "security_rule" {
    for_each = local.inbound_rules

    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = security_rule.value.ports
      source_address_prefixes    = security_rule.value.source_ranges
      destination_address_prefix = azurerm_subnet.application.address_prefixes[0]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "application" {
  subnet_id                 = azurerm_subnet.application.id
  network_security_group_id = azurerm_network_security_group.application.id
}
