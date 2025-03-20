@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  properties: {
    enableRbacAuthorization: true
    tenantId: subscription().tenantId
    enableSoftDelete: true
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}


@description('The resource id.')
output id string = keyVault.id

@description('The name of the key vault.')
output name string = keyVault.name
