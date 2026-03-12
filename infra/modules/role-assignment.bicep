@description('Principal ID to assign the role to')
param principalId string

@description('Type of the principal')
@allowed(['User', 'Group', 'ServicePrincipal'])
param principalType string

@description('Role definition ID (GUID) to assign')
param roleDefinitionId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, roleDefinitionId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}
