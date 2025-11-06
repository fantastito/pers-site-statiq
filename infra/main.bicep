@description('Name of the Storage Account')
param storageAccountName string = 'simonbuddenweb'

@description('Azure region')
param location string = resourceGroup().location

@description('Index document for static website')
param indexDocument string = 'index.html'

@description('Error document for static website')
param errorDocument string = '404.html'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    staticWebsite: {
      enabled: true
      indexDocument: indexDocument
      error404Document: errorDocument
    }
  }
}

output staticWebsiteUrl string = storageAccount.properties.primaryEndpoints.web