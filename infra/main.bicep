@description('Name of the Storage Account')
param storageAccountName string = 'simonbuddenweb'

@description('Azure region')
param location string = resourceGroup().location

@description('Custom domain for the site')
param customDomainName string = 'www.simonbudden.dev'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: true
  }
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: '${storageAccountName}-afd-profile'
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  name: '${storageAccountName}-afd-endpoint'
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  name: 'origin-group'
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probeIntervalInSeconds: 100
      probePath: '/'
      probeProtocol: 'Https'
      probeRequestType: 'GET'
    }
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  name: 'storage-origin'
  parent: originGroup
  properties: {
    hostName: '${storageAccount.name}.z33.web.core.windows.net'
    httpsPort: 443
    originHostHeader: '${storageAccount.name}.z33.web.core.windows.net'
    priority: 1
    weight: 1000
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  name: 'default-route'
  parent: frontDoorEndpoint
  dependsOn: [
    origin
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}

resource customDomain 'Microsoft.Cdn/profiles/customDomains@2025-06-01' = {
  name: 'simonbudden-dev'
  parent: frontDoorProfile
  properties: {
    hostName: customDomainName
  }
}

resource customDomainHttps 'Microsoft.Cdn/profiles/customDomains/customHttpsConfigurations@2023-05-01' = {
  name: 'https-config'
  parent: customDomain
  properties: {
    certificateType: 'ManagedCertificate'
    protocolType: 'ServerNameIndication'
    minimumTlsVersion: 'TLS1_2'
  }
}

output staticWebsiteUrl string = storageAccount.properties.primaryEndpoints.web
output frontDoorEndpointUrl string = 'https://${frontDoorEndpoint.name}.azurefd.net'
output customDomainUrl string = 'https://${customDomainName}'
