@description('Location for resources')
param location string

@description('Tags for resources')
param tags object

@description('Name of the user-assigned managed identity')
param identityName string

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: identityName
  location: location
  tags: tags
}

output identityId string = identity.id
output principalId string = identity.properties.principalId
output clientId string = identity.properties.clientId
