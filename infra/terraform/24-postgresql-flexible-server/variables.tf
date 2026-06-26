variable "subscription_id" {
  description = "Azure subscription ID for the deployment"
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID for the deployment"
  type        = string
}

variable "resource_group_name" {
  description = "Existing Azure resource group name"
  type        = string
}

variable "location" {
  description = "Azure region for resources deployed into the existing resource group"
  type        = string
  default     = "eastus2"
}

variable "application_name" {
  description = "Display name for the Entra app registration and service principal"
  type        = string
  default     = "calc-project-app-01"
}

variable "github_repository" {
  description = "GitHub repository allowed to exchange OIDC tokens with the Entra app registration"
  type        = string
  default     = "multi-layer-perceptron/ghcp-dotnet-calculator"
}

variable "github_ref" {
  description = "Git reference allowed to exchange OIDC tokens with the Entra app registration"
  type        = string
  default     = "refs/heads/main"
}

variable "key_vault_name" {
  description = "Key Vault name to create if globally available"
  type        = string
  default     = "calc-kvt-01"
}

variable "postgresql_server_name" {
  description = "Globally unique Azure Database for PostgreSQL Flexible Server name"
  type        = string
  default     = "calc-pgflex-dev-01"
}

variable "postgresql_database_name" {
  description = "Database name reserved for calculator test data"
  type        = string
  default     = "calculator_test_data"
}

variable "postgresql_zone" {
  description = "Availability zone for the PostgreSQL Flexible Server primary instance"
  type        = string
  default     = "2"
}

variable "postgresql_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
}

variable "postgresql_sku_name" {
  description = "PostgreSQL Flexible Server SKU name for dev/test"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgresql_storage_mb" {
  description = "PostgreSQL storage size in MB"
  type        = number
  default     = 32768
}

variable "postgresql_admin_username" {
  description = "PostgreSQL administrator username stored in Key Vault"
  type        = string
  default     = "postgres_user"
}

variable "postgresql_admin_password" {
  description = "PostgreSQL administrator password stored in Key Vault"
  type        = string
  sensitive   = true
}

variable "postgresql_admin_username_secret_name" {
  description = "Key Vault secret name for the PostgreSQL administrator username"
  type        = string
  default     = "postgresql-admin-username"
}

variable "postgresql_admin_password_secret_name" {
  description = "Key Vault secret name for the PostgreSQL administrator password"
  type        = string
  default     = "postgresql-admin-password"
}

variable "postgresql_entra_admin_object_id" {
  description = "Optional Entra object ID to configure as PostgreSQL administrator"
  type        = string
  default     = null
}

variable "postgresql_entra_admin_name" {
  description = "Optional Entra principal name to configure as PostgreSQL administrator"
  type        = string
  default     = null
}

variable "postgresql_entra_admin_type" {
  description = "Entra principal type for the PostgreSQL administrator"
  type        = string
  default     = "ServicePrincipal"
}

variable "postgresql_additional_entra_admin_object_id" {
  description = "Entra object ID of the additional PostgreSQL administrator. Required when postgresql_additional_entra_admin_name is set."
  type        = string
  default     = null

  validation {
    condition = (
      var.postgresql_additional_entra_admin_object_id == null
    ) == (var.postgresql_additional_entra_admin_name == null)
    error_message = "postgresql_additional_entra_admin_object_id and postgresql_additional_entra_admin_name must both be set or both be null."
  }
}

variable "postgresql_additional_entra_admin_name" {
  description = "UPN or display name of the additional Entra principal to configure as PostgreSQL administrator"
  type        = string
  default     = null
}

variable "postgresql_additional_entra_admin_type" {
  description = "Entra principal type for the additional PostgreSQL administrator (User, Group, or ServicePrincipal)"
  type        = string
  default     = "User"
}