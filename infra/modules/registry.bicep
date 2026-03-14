@description('Location for resources')
param location string

@description('Tags for resources')
param tags object

@description('Name of the container registry')
param registryName string

@description('Principal ID of the managed identity for AcrPull role assignment')
param identityPrincipalId string

resource registry 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
  name: registryName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
  }
}

// AcrPull role: 7f951dda-4ed3-4680-a7ca-43fe172d538d
resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(registry.id, identityPrincipalId, '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  scope: registry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: identityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output registryId string = registry.id
output loginServer string = registry.properties.loginServer
