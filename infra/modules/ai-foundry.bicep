@description('Location for resources')
param location string

@description('Tags for resources')
param tags object

@description('Name of the Azure AI Services account')
param accountName string

resource aiAccount 'Microsoft.CognitiveServices/accounts@2025-09-01' = {
  name: accountName
  location: location
  tags: tags
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: accountName
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: true
  }
}

resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-09-01' = {
  parent: aiAccount
  name: 'gpt-4o'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-08-06'
    }
  }
}

resource phiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-09-01' = {
  parent: aiAccount
  name: 'phi-4'
  dependsOn: [gpt4oDeployment]
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'Microsoft'
      name: 'Phi-4'
      version: '7'
    }
  }
}

output aiAccountEndpoint string = aiAccount.properties.endpoint
output aiAccountName string = aiAccount.name
