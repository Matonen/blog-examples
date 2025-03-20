targetScope = 'subscription'

extension graphV1

param env string
param solution string

param location string = deployment().location

param allowedIpAddresses string[]

resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'rg-${solution}-${env}'
  location: location
}

var sqlAdminGroupName = 'SQL Server Admins'
resource sqlAdminGroup 'Microsoft.Graph/groups@v1.0' = {
  displayName: sqlAdminGroupName
  uniqueName: toLower(replace(sqlAdminGroupName, ' ', '-'))
  mailNickname: toLower(replace(sqlAdminGroupName, ' ', '-'))
  securityEnabled: true
  mailEnabled: false
  owners: [deployer().objectId]
  members: [deployer().objectId]
}

var appName = 'sp-fabric-sql-statereader'
resource app 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: appName
  displayName: appName
}

resource sp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: app.appId
}

module sqlserver '../../modules/sql/server.bicep' = {
  name: 'sqlserver'
  params: {
    name: 'sql-${solution}-${env}'
    location: location
    adminGroupName: sqlAdminGroup.uniqueName
    allowedIpAddresses: allowedIpAddresses
  }
  scope: rg
}

module database '../../modules/sql/serverless-database.bicep' = {
  name: 'database'
  params: {
    name: 'sqldb-fabric-mirroring'
    location: location
    serverName: sqlserver.outputs.name
  }
  scope: rg
}
