//currently not in use!

@description('Location for all resources.')
param deploymentLocation string = resourceGroup().location
@description('Name of the VNET')
param virtualNetworkName string = 'vNet'
@description('Name of the subnet in the virtual network')
param subnetName string = 'Subnet'

var subnetAddressPrefix = '10.1.0.0/24'
var addressPrefix = '10.1.0.0/16'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: deploymentLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}
