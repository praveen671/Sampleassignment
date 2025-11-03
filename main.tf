provider "azurerm" {
  features {}
  subscription_id = "8b531410-b29b-4609-93e8-a1a8679bd9e2"
}

resource "random_password" "sql" {
  length  = 16
  special = true
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}



resource "azurerm_service_plan" "example" {
  name                = "${var.prefix}-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}
 

resource "azurerm_linux_web_app" "web" {
  name                = "${var.prefix}temp65735-web"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}
}

resource "azurerm_mssql_server" "sqlserver" {
  name                         = "${var.prefix}temp65735-sqlsrv"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_user
  administrator_login_password = random_password.sql.result
  public_network_access_enabled = true
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "${var.prefix}-sqldb"
  server_id = azurerm_mssql_server.sqlserver.id
  sku_name  = "Basic"
}

output "app_service_url" {
  value = azurerm_linux_web_app.web.default_hostname
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sqlserver.fully_qualified_domain_name
}