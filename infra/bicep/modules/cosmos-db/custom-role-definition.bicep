@description('A user-friendly name for the role definition. Must be unique for the database account.')
param roleName string

@description('The reource id of the CosmosDB account to create the role for.')
param accountId string

@description('The list of assignable scopes for the role definition.')
param assignableScopes string[]

@description('The list of data actions for the role definition. Valid are listed in https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/security/reference-data-plane-actions#data-actions')
param dataActions string[] = []

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = {
  name: last(split(accountId, '/'))
}

var roleDefinitionId = guid(account.id, roleName)

resource customRole 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-11-15' = {
  parent: account
  name: roleDefinitionId
  properties: {
    roleName: roleName
    type: 'CustomRole'
    assignableScopes: assignableScopes
    permissions: [
      {
        dataActions: union(dataActions, ['Microsoft.DocumentDB/databaseAccounts/readMetadata'])
        notDataActions: []
      }
    ]
  }
}

@description('Role definition id.')
output id string = customRole.id
