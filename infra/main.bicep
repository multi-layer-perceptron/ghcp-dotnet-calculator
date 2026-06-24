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

@description('Tags applied to all deployed resources.')
param tags object = {}

var normalizedEnvironmentName = toLower(replace(environmentName, '_', '-'))
var resourceToken = uniqueString(resourceGroup().id, environmentName)
var baseName = '${resourcePrefix}-${normalizedEnvironmentName}-${resourceToken}'
var commonTags = union(tags, {
  'azd-env-name': environmentName
  workload: 'calculator'
})

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
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
    publicNetworkAccess: 'Enabled'
    siteConfig: {
      alwaysOn: true
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
      ]
    }
  }
}

output AZURE_LOCATION string = location
output SERVICE_WEB_NAME string = webApp.name
output SERVICE_WEB_URI string = 'https://${webApp.properties.defaultHostName}'
