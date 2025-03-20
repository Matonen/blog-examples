extension graphV1

@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('The name of the Entra ID group that will be the server admin.')
param adminGroupName string

@description('The list of allowed IP addresses.')
param allowedIpAddresses string[]

resource adminGroup 'Microsoft.Graph/groups@v1.0' existing = {
  uniqueName: adminGroupName
}

resource server 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimalTlsVersion: '1.2'
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      principalType: 'Group'
      sid: adminGroup.id
      login: adminGroup.displayName
    }
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource allowAzureServices 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: server
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource allowedIpFirewallRules 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = [for (ip, idx) in allowedIpAddresses: {
  parent: server
  name: 'AllowIPRule${idx}'
  properties: {
    startIpAddress: ip
    endIpAddress: ip
  }
}]

@description('The server name.')
output name string = server.name
