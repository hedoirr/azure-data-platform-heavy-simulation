@description('Application prefix used for naming')
param appPrefix string

@description('Environment name (dev, qa, prod)')
param environmentName string

@description('Azure region')
param location string = 'northeurope'

@description('SQL admin username')
param sqlAdminUser string

@secure()
@description('SQL admin password')
param sqlAdminPassword string

var storageAccountName = toLower('st${appPrefix}${environmentName}01')
var sqlServerName = toLower('sql${appPrefix}${environmentName}01')
var dataFactoryName = 'adf-${appPrefix}-${environmentName}-01'
var databricksName = 'dbw-${appPrefix}-${environmentName}-01'
var sqlDatabaseName = 'sqldb-${appPrefix}-${environmentName}-01'

var tags = {
  environment: environmentName
  project: 'azure-data-platform'
  owner: 'edoir'
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

resource bronzeContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.name}/default/bronze'
}

resource silverContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.name}/default/silver'
}

resource goldContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.name}/default/gold'
}

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
}

resource databricks 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: databricksName
  location: location
  tags: tags
  sku: {
    name: 'standard'
  }
  properties: {
    managedResourceGroupId: '${resourceGroup().id}-dbx'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlAdminUser
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlFirewall 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}
