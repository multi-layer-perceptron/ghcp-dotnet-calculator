data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

locals {
  github_oidc_subject = "repo:${var.github_repository}:ref:${var.github_ref}"
}

// =====================================================
// GitHub OIDC Identity
// =====================================================

data "azuread_application" "main" {
  display_name = var.application_name
}

data "azuread_service_principal" "main" {
  client_id = data.azuread_application.main.client_id
}

resource "azurerm_role_assignment" "github_oidc_contributor" {
  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.main.object_id
}

// =====================================================
// Key Vault
// =====================================================

resource "azurerm_key_vault" "main" {
  name                          = var.key_vault_name
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.main.name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  public_network_access_enabled = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7

  tags = {
    environment = "dev"
    project     = "calculator"
    workflow    = "24-deploy-resources-workflow"
  }
}

resource "azurerm_role_assignment" "github_oidc_key_vault_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azuread_service_principal.main.object_id
}

resource "azurerm_role_assignment" "current_identity_key_vault_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

// =====================================================
// PostgreSQL Flexible Server
// =====================================================

resource "azurerm_postgresql_flexible_server" "main" {
  name                          = var.postgresql_server_name
  resource_group_name           = data.azurerm_resource_group.main.name
  location                      = var.location
  version                       = var.postgresql_version
  sku_name                      = var.postgresql_sku_name
  storage_mb                    = var.postgresql_storage_mb
  backup_retention_days         = 7
  administrator_login           = var.postgresql_admin_username
  administrator_password        = var.postgresql_admin_password
  public_network_access_enabled = true

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = var.tenant_id
  }

  tags = {
    environment = "dev"
    project     = "calculator"
    workflow    = "24-deploy-resources-workflow"
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "main" {
  server_name         = azurerm_postgresql_flexible_server.main.name
  resource_group_name = data.azurerm_resource_group.main.name
  tenant_id           = var.tenant_id
  object_id           = coalesce(var.postgresql_entra_admin_object_id, data.azuread_service_principal.main.object_id)
  principal_name      = coalesce(var.postgresql_entra_admin_name, var.application_name)
  principal_type      = var.postgresql_entra_admin_type
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.postgresql_database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}