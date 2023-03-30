param redisCacheName string
param vnetName string
param subnetName string
param location string = resourceGroup().location


// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-providers
// https://learn.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations
var vnetResourceType = 'Microsoft.Network/virtualNetworks'
var subnetResourceType = '${vnetResourceType}/subnets'

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name:  'privatelink.redis.cache.windows.net'
  location: 'global'
}
resource privateDnsZoneVNetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDnsZone
  name: uniqueString(resourceGroup().id)
  location: 'global'
  properties: {
      registrationEnabled: false
      virtualNetwork: {
          id:   resourceId(vnetResourceType, vnetName)
      }
  }
}

resource redisCache 'Microsoft.Cache/redis@2021-06-01' = {
  name: redisCacheName
  location: location
  tags: {
    deployment: 'bicep'
  }
  properties: {
    enableNonSslPort: false
    minimumTlsVersion: '1.2'    
    publicNetworkAccess: 'Disabled'
    redisConfiguration: {
      'maxfragmentationmemory-reserved': '299'
      'maxmemory-delta': '299'
      'maxmemory-reserved': '299'
    }
    redisVersion: '6.0.14'
    sku: {
      capacity: 2
      family: 'C'
      name: 'Basic'
    }
  }
}

resource redisCachePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'redisendpoint'
  location: location
  properties: {
    subnet: {
      id: resourceId(subnetResourceType, vnetName, subnetName)
    }
    privateLinkServiceConnections: [
      {
        name: 'redisendpointconnectioname'
        properties: {
          privateLinkServiceId: redisCache.id
          groupIds: [
            'redisCache'
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  name: 'default'
  parent: redisCachePrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink_redis_cache_windows_net'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
