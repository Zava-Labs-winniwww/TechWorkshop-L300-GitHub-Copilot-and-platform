targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment used to generate resource names')
param environmentName string

@description('Primary location for all resources')
param location string

@description('Principal ID of the deploying user')
param principalId string

var tags = {
  'azd-env-name': environmentName
  environment: 'dev'
}

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module monitoring './modules/monitoring.bicep' = {
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: 'log-${resourceToken}'
    appInsightsName: 'appi-${resourceToken}'
  }
}

module identity './modules/identity.bicep' = {
  scope: rg
  params: {
    location: location
    tags: tags
    identityName: 'id-${resourceToken}'
  }
}

module registry './modules/registry.bicep' = {
  scope: rg
  params: {
    location: location
    tags: tags
    registryName: 'acr${resourceToken}'
    identityPrincipalId: identity.outputs.principalId
  }
}

module appService './modules/app-service.bicep' = {
  scope: rg
  params: {
    location: location
    tags: tags
    appServicePlanName: 'plan-${resourceToken}'
    appServiceName: 'app-${resourceToken}'
    identityId: identity.outputs.identityId
    identityClientId: identity.outputs.clientId
    registryLoginServer: registry.outputs.loginServer
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
  }
}

module aiFoundry './modules/ai-foundry.bicep' = {
  scope: rg
  params: {
    location: location
    tags: tags
    accountName: 'ai-${resourceToken}'
  }
}

// Grant the deploying user the Contributor role on the resource group
module deployerAccess './modules/role-assignment.bicep' = {
  scope: rg
  params: {
    principalId: principalId
    principalType: 'User'
    roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  }
}

output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = registry.outputs.loginServer
output AZURE_APP_SERVICE_NAME string = appService.outputs.appServiceName
output AZURE_APP_SERVICE_URL string = appService.outputs.appServiceUrl
