@description('The IDs of the principals to assign the role to.')
param principalIds array

@description('The name of the built in role to assign.')
param builtInRoleName string?

@description('The ID of the custom role definition to assign.')
param customRoleDefinitionId string?

@description('Name of the account.')
param accountName string

@description('The subscope to assign the role to. Example: /dbs/<db>/colls/<container>')
param subScope string

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = {
  name: accountName
}

var builtInRoleNames = {
  'Cosmos DB Built-in Data Reader': '${account.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000001'
  'Cosmos DB Built-in Data Contributor': '${account.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002'
}

var roleDefinitionId = !empty(builtInRoleName) ? builtInRoleNames[builtInRoleName!] : customRoleDefinitionId

resource roleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-11-15' = [
  for principalId in principalIds: {
    name: guid(account.name, principalId, roleDefinitionId)
    parent: account
    properties: {
      roleDefinitionId: roleDefinitionId
      principalId: principalId
      scope: empty(subScope) ? account.id : '${account.id}${subScope}' 
    }
  }
]
