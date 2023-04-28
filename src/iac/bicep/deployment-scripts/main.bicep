@description('Location for all resources.')
param location string = resourceGroup().location
param servicePrincipalClientId string
@secure()
param servicePrincipalClientSecret string
@description('Name of the host on the DNS.')
param customHostName string
@description('Path to index html document inside the storage container.')
param indexDocument string = 'index.html'
@description('Path to error html document inside the storage container.')
param erroDocument string = 'index.html'

var storageAccountName = 'storage${uniqueString(resourceGroup().id)}'
var endpointName = 'endpoint-${uniqueString(resourceGroup().id)}'
var profileName = 'cdn-${uniqueString(resourceGroup().id)}'
var customDomainName = 'domain-${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: storageAccountName
  location: location
  tags: {
    displayName: storageAccountName
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource cdnProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: profileName
  location: location
  tags: {
    displayName: profileName
  }
  sku: {
    name: 'Standard_Verizon'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/endpoints@2021-06-01' = {
  parent: cdnProfile
  name: endpointName
  location: location
  tags: {
    displayName: endpointName
  }
  properties: {
    originHostHeader: deploymentScriptStorage.properties.outputs.originHost
    isHttpAllowed: true
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    contentTypesToCompress: [
      'text/plain'
      'text/html'
      'text/css'
      'application/x-javascript'
      'text/javascript'
    ]
    isCompressionEnabled: true
    origins: [
      {
        name: 'origin1'
        properties: {
          hostName: deploymentScriptStorage.properties.outputs.originHost
        }
      }
    ]
  }
}

resource deploymentScriptStorage 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'enableStaticWebsite'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.42.0'
    forceUpdateTag: '1' // only needs to be exectued once
    retentionInterval: 'PT4H' // retention: 4 hours
    scriptContent: loadTextContent('enable-static-website.sh')
    environmentVariables: [
      {
        name: 'TenantId'
        value: subscription().tenantId
      }
      {
        name: 'StorageAccountName'
        value: storageAccount.name
      }
      {
        name: 'ServicePrincipalClientId'
        value: servicePrincipalClientId
      }
      {
        name: 'ServicePrincipalClientSecret'
        secureValue: servicePrincipalClientSecret
      }
      {
        name: 'IndexDocument'
        value: indexDocument
      }
      {
        name: 'ErrorDocument'
        value: erroDocument
      }
    ]
  }
}

resource customDomain 'Microsoft.Cdn/profiles/endpoints/customdomains@2021-06-01' = {
  parent: endpoint
  name: customDomainName
  properties: {
    hostName: customHostName
  }
  dependsOn: []
}

resource deploymentScriptCdn 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'enableHttpsCdn'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.42.0'
    forceUpdateTag: '1' // only needs to be exectued once
    retentionInterval: 'PT4H' // retention: 4 hours
    scriptContent: loadTextContent('enable-https.sh')
    environmentVariables: [
      {
        name: 'TenantId'
        value: subscription().tenantId
      }
      {
        name: 'ServicePrincipalClientId'
        value: servicePrincipalClientId
      }
      {
        name: 'ServicePrincipalClientSecret'
        secureValue: servicePrincipalClientSecret
      }
      {
        name: 'CdnProfileName'
        value: cdnProfile.name
      }
      {
        name: 'CdnEndpointName'
        value: endpoint.name
      }
      {
        name: 'CustomDomainName'
        value: customDomain.name
      }
    ]
  }
}

output hostName string = endpoint.properties.hostName
output customHostName string = customHostName
output originHostHeader string = endpoint.properties.originHostHeader
