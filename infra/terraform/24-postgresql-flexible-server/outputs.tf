output "key_vault_uri" {
  description = "URI of the calculator Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "postgresql_server_fqdn" {
  description = "Fully qualified domain name of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgresql_database_name" {
  description = "Calculator test data database name"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "postgresql_admin_username_secret_name" {
  description = "Key Vault secret name containing the PostgreSQL administrator username"
  value       = var.postgresql_admin_username_secret_name
}

output "postgresql_admin_password_secret_name" {
  description = "Key Vault secret name containing the PostgreSQL administrator password"
  value       = var.postgresql_admin_password_secret_name
}