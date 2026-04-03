param appPrefix string
param environmentName string
param location string = 'northeurope'

var storageAccountName = toLower('st${appPrefix}${environmentName}01')
var sqlServerName = toLower('sql${appPrefix}${environmentName}01')
var dataFactoryName = 'adf-${appPrefix}-${environmentName}-01'
var databricksName = 'dbw-${appPrefix}-${environmentName}-01'
var sqlDatabaseName = 'sqldb-${appPrefix}-${environmentName}-01'

@description('Environment name (dev, qa, prod)')
param environment string

@description('Azure region')
param location string = resourceGroup().location

@description('Storage account name')
param storageAccountName string

@description('Data Factory name')
param dataFactoryName string

@description('Databricks workspace name')
param databricksName string

@description('SQL server name')
param sqlServerName string

@description('SQL database name')
param sqlDatabaseName string

@description('SQL admin username')
param sqlAdminUser string

@secure()
@description('SQL admin password (use Key Vault in real scenarios)')
param sqlAdminPassword string
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: 'kv-${environment}'
} // this would come from Key Vault

var sqlPassword = sqlAdminPassword
// =====================
// TAGS (Padrão empresa)
// =====================
var tags = {
  environment: environment
  project: 'azure-data-platform'
  owner: 'edoir'
}

// =====================
// STORAGE ACCOUNT
// =====================
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

// Containers
resource bronzeContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.name}/default/bronze'
}

resource silverContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.name}/default/silver'
}

resource goldContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.name}/default/gold'
}

// =====================
// DATA FACTORY
// =====================
resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
}

// =====================
// DATABRICKS
// =====================
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

// =====================
// SQL SERVER
// =====================
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

// Firewall (permitir Azure services)
resource sqlFirewall 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  name: '${sqlServer.name}/AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  networkAcls: {
  defaultAction: 'Deny'
  bypass: 'AzureServices'
    }
  }
}

// =====================
// DATABASE
// =====================
resource sqlDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: '${sqlServer.name}/${sqlDatabaseName}'
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
