targetScope = 'resourceGroup'

@description('The Azure Developer CLI environment name.')
param environmentName string

@description('The Azure region where resources are deployed.')
param location string = resourceGroup().location

@description('Short prefix used in Azure resource names.')
param resourcePrefix string = 'calc'

@description('The azd service name. This must match the service key in azure.yaml.')
param serviceName string = 'web'

@description('The Linux App Service runtime stack.')
param runtimeStack string = 'DOTNETCORE|10.0'

@allowed([
  'B1'
  'S1'
  'P0v3'
])
@description('The App Service plan SKU.')
param appServicePlanSkuName string = 'B1'

@description('The PostgreSQL administrator login name.')
param postgresAdministratorLogin string = 'calcadmin'

@secure()
@description('The PostgreSQL administrator login password.')
param postgresAdministratorLoginPassword string

@description('The PostgreSQL database name used by the calculator application.')
param postgresDatabaseName string = 'calculator'

@description('The PostgreSQL Flexible Server SKU name.')
param postgresSkuName string = 'Standard_B1ms'

@description('The PostgreSQL Flexible Server SKU tier.')
param postgresSkuTier string = 'Burstable'

@description('The PostgreSQL Flexible Server storage size in gibibytes.')
param postgresStorageSizeGB int = 32

@description('The PostgreSQL engine version.')
param postgresVersion string = '17'

@description('The expiration timestamp for the Key Vault PostgreSQL connection string value.')
param postgresConnectionStringExpiresOn string = dateTimeAdd(utcNow('u'), 'P90D')

@description('Tags applied to all deployed resources.')
param tags object = {}

var normalizedEnvironmentName = toLower(replace(environmentName, '_', '-'))
var resourceToken = uniqueString(subscription().id, resourceGroup().id, location, environmentName)
var baseName = '${resourcePrefix}-${normalizedEnvironmentName}-${resourceToken}'
var keyVaultName = take('kv${resourcePrefix}${resourceToken}', 24)
var postgresConnectionStringSecretName = 'calculator-postgresql-connection-string'
var postgresHostName = '${postgresServer.name}.postgres.database.azure.com'
var postgresConnectionString = 'Host=${postgresHostName};Port=5432;Database=${postgresDatabase.name};Username=${postgresAdministratorLogin};Password=${postgresAdministratorLoginPassword};Ssl Mode=Require;'
var commonTags = union(tags, {
  'azd-env-name': environmentName
  workload: 'calculator'
})

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${baseName}-uami'
  location: location
  tags: commonTags
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${baseName}-log'
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${baseName}-appi'
  location: location
  kind: 'web'
  tags: commonTags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: commonTags
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
    publicNetworkAccess: 'Enabled'
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 90
  }
}

resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: '${baseName}-pg'
  location: location
  tags: commonTags
  sku: {
    name: postgresSkuName
    tier: postgresSkuTier
  }
  properties: {
    administratorLogin: postgresAdministratorLogin
    administratorLoginPassword: postgresAdministratorLoginPassword
    authConfig: {
      activeDirectoryAuth: 'Disabled'
      passwordAuth: 'Enabled'
      tenantId: subscription().tenantId
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    createMode: 'Default'
    highAvailability: {
      mode: 'Disabled'
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
    storage: {
      autoGrow: 'Enabled'
      storageSizeGB: postgresStorageSizeGB
    }
    version: postgresVersion
  }
}

resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2024-08-01' = {
  name: postgresDatabaseName
  parent: postgresServer
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

resource postgresAllowAzureServices 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2024-08-01' = {
  name: 'AllowAzureServices'
  parent: postgresServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource postgresConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: postgresConnectionStringSecretName
  parent: keyVault
  properties: {
    attributes: {
      exp: dateTimeToEpoch(postgresConnectionStringExpiresOn)
    }
    contentType: 'connection-string'
    value: postgresConnectionString
  }
}

resource keyVaultSecretsOfficerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, userAssignedIdentity.id, 'Key Vault Secrets Officer')
  scope: keyVault
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: '${baseName}-plan'
  location: location
  kind: 'linux'
  tags: commonTags
  sku: {
    name: appServicePlanSkuName
  }
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: '${baseName}-${serviceName}'
  location: location
  kind: 'app,linux'
  tags: union(commonTags, { 'azd-service-name': serviceName })
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    keyVaultReferenceIdentity: userAssignedIdentity.id
    clientAffinityEnabled: false
    publicNetworkAccess: 'Enabled'
    siteConfig: {
      alwaysOn: true
      cors: {
        allowedOrigins: []
        supportCredentials: false
      }
      ftpsState: 'Disabled'
      healthCheckPath: '/health'
      http20Enabled: true
      linuxFxVersion: runtimeStack
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'ConnectionStrings__CalculatorPostgreSql'
          value: '@Microsoft.KeyVault(SecretUri=${postgresConnectionStringSecret.properties.secretUriWithVersion})'
        }
      ]
    }
  }
  dependsOn: [
    keyVaultSecretsOfficerRoleAssignment
  ]
}

resource webAppDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${webApp.name}-diag'
  scope: webApp
  properties: {
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspace.id
  }
}

output AZURE_LOCATION string = location
output POSTGRESQL_DATABASE_NAME string = postgresDatabase.name
output POSTGRESQL_SERVER_NAME string = postgresServer.name
output RESOURCE_GROUP_ID string = resourceGroup().id
output SERVICE_WEB_NAME string = webApp.name
output SERVICE_WEB_URI string = 'https://${webApp.properties.defaultHostName}'
