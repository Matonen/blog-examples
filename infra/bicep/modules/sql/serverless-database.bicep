@description('The name of the database.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('The name of the server.')
param serverName string

@description('Whether or not the database uses free monthly limits')
param useFreeLimit bool = true

@description('The collation of the database.')
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('The storage account type to be used to store backups for this database.')
param requestedBackupStorageRedundancy string = 'Local'

@allowed(['GP_S_Gen5'])
param skuName string = 'GP_S_Gen5'

@allowed(['GeneralPurpose'])
param skuTier string = 'GeneralPurpose'

@description('The maximum number of vCores.')
param maxVCores int = 1

resource server 'Microsoft.Sql/servers@2024-05-01-preview' existing = {
  name: serverName
}

resource database 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  name: name
  parent: server
  location: location
  sku: {
    name: skuName 
    tier: skuTier
    family: 'Gen5'
    capacity: maxVCores
  } 
  properties: {
    maxSizeBytes: 34359738368 // 32 GB
    collation: collation
    useFreeLimit: useFreeLimit
    requestedBackupStorageRedundancy: requestedBackupStorageRedundancy
    freeLimitExhaustionBehavior: 'AutoPause'
    minCapacity: json('0.5')
    autoPauseDelay: 60
    isLedgerOn: false
    zoneRedundant: false
  }
}
