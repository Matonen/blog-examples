targetScope = 'subscription'

param env string

param solution string

param location string = deployment().location

param enableFreeTier bool = true

resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'rg-${solution}-${env}'
  location: location
}

module cosmosdb '../../modules/cosmos-db/account.bicep' = {
  name: 'cosmosdb'
  params: {
    name: 'cosmos-${solution}-${env}'
    location: location
    enableFreeTier: enableFreeTier
    databases: [
      {
        name: 'blog'
        throughput: 400
        containers: [
          {
            name: 'posts'
            partitionKeyPath: '/type'
            defaultTtl: -1
          }
          {
            name: 'users'
            partitionKeyPath: '/type'
            defaultTtl: -1
          }
        ]
      }
    ]
  }
  scope: rg
}

module postsContainerReaderCustomRoleDefinition '../../modules/cosmos-db/custom-role-definition.bicep' = {
  name: 'postsContainerReaderCustomRoleDefinition'
  params: {
    roleName: 'Posts Container Reader'
    accountId: cosmosdb.outputs.id
    assignableScopes: [
      '${cosmosdb.outputs.id}/dbs/blog/colls/posts'
    ]
    dataActions: [
      'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
      'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
      'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
    ]
  }
  scope: rg
}

module usersContainerWriterCustomRoleDefinition '../../modules/cosmos-db/custom-role-definition.bicep' = {
  name: 'usersContainerWriterCustomRoleDefinition'
  params: {
    roleName: 'Users Container Writer'
    accountId: cosmosdb.outputs.id
    assignableScopes: [
      '${cosmosdb.outputs.id}/dbs/blog/colls/users'
    ]
    dataActions: [
      'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
      'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
    ]
  }
  scope: rg
}

module postsContainerReaderRoleAssignment '../../modules/cosmos-db/data-role-assignment.bicep' = {
  name: 'postsContainerReaderRoleAssignment'
  params: {
    principalIds: [deployer().objectId]
    accountName: cosmosdb.outputs.name
    customRoleDefinitionId: postsContainerReaderCustomRoleDefinition.outputs.id
    subScope: '/dbs/blog/colls/posts'
  }
  scope: rg
}

module usersContainerWriterRoleAssignment '../../modules/cosmos-db/data-role-assignment.bicep' = {
  name: 'usersContainerWriterRoleAssignment'
  params: {
    principalIds: [deployer().objectId]
    accountName: cosmosdb.outputs.name
    customRoleDefinitionId: usersContainerWriterCustomRoleDefinition.outputs.id
    subScope: '/dbs/blog/colls/users'
  }
  scope: rg
}
