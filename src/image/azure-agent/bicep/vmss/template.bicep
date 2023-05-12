/* 
az deployment group what-if `
--name vmssDeployment  `
--resource-group XXXXXXXXXXXXXXXXXXXXXX  `
--template-file azure-vmss.bicep `
--parameters `
name="vmss-agent-windows2022" `
acgName="XXXXXXXXXXXXXXXXXXXXXX" `
imgName="vm-agent-windows2022" `
vmssPrefix="XXXXXXXXXXXXXXXXXXXXXX" `
adminUsername="XXXXXXXXXXXXXXXXXXXXXX" `
adminPasswordOrKey="XXXXXXXXXXXXXXXXXXXXXX" `
vnetResourceGroupName="XXXXXXXXXXXXXXXXXXXXXX" `
virtualNetworkName="XXXXXXXXXXXXXXXXXXXXXX" `
subnetName="XXXXXXXXXXXXXXXXXXXXXX" 
*/

/* 
az deployment group what-if `
--name vmssDeployment  `
--resource-group XXXXXXXXXXXXXXXXXXXXXX  `
--template-file .\azure-vmss.bicep `
--parameters `
name="vmss-agent-ubuntu2204" `
acgName="XXXXXXXXXXXXXXXXXXXXXX" `
imgName="vm-agent-ubuntu2204" `
vmssPrefix="XXXXXXXXXXXXXXXXXXXXXX" `
adminUsername="azureuser" `
adminPasswordOrKey="ssh-rsa XXXXXXXXXXXXXX..." `
authenticationType="sshPublicKey" `
vnetResourceGroupName="XXXXXXXXXXXXXXXXXXXXXX" `
virtualNetworkName="XXXXXXXXXXXXXXXXXXXXXX" `
subnetName="XXXXXXXXXXXXXXXXXXXXXX" 
*/

@description('Location for all resources.')
param deploymentLocation string = resourceGroup().location
@description('Name of the deloyed VMSS.')
param name string
@description('Prefix for various properties of the VMSS.')
param vmssPrefix string
@description('SKU of any VM inside the VMSS.')
param imageSku string = 'Standard_D4s_v3'
@description('Username for the Virtual Machine.')
param adminUsername string
@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string
@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'
@description('Resource group name of existing VNET where VMSS will be deployed.')
param vnetResourceGroupName string
@description('Name of existing VNET where VMSS will be deployed.')
param virtualNetworkName string
@description('Name of existing subnet where VMSS will be deployed.')
param subnetName string
@description('Resource id of the image referenced by the VMSS.')
param imgId string = ''

var nicName = '${vmssPrefix}Nic'
var ipConfigName = '${vmssPrefix}IPConfig'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

var imageCanonicalUbunutuReference = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18.04-LTS'
  version: 'latest'
}

var imageCustomReference =  {
  id: imgId
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2022-08-01' = {
  name: name
  location: deploymentLocation
  sku: {
    capacity: 0
    name: imageSku
  }
  properties: {
    orchestrationMode: 'Uniform'
    overprovision: false
    platformFaultDomainCount: 1
    singlePlacementGroup: false
    upgradePolicy: {
      mode: 'Manual'
      rollingUpgradePolicy: {}
    }
    virtualMachineProfile: {
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: nicName
            properties: {
              ipConfigurations: [
                {
                  name: ipConfigName
                  properties: {
                    subnet: {
                      id: resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
                    }
                  }
                }
              ]
              primary: true
            }
          }
        ]
      }
      osProfile: {
        computerNamePrefix: vmssPrefix
        adminUsername: adminUsername
        adminPassword: adminPasswordOrKey
        linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)

      }
      storageProfile: {
        imageReference: empty(imgId) ? imageCanonicalUbunutuReference : imageCustomReference
        osDisk: {
          caching: 'ReadWrite'
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: null
          }
        }
      }
    }
  }
}

resource customExtension 'Microsoft.Compute/virtualMachineScaleSets/extensions@2021-07-01' = if (empty(imgId)) {
  name: 'CustomScript'
  parent: vmss
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.Extensions'
    settings: {
      script: loadFileAsBase64('../../scripts/install-requirements.sh')
    }
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
  }
}
