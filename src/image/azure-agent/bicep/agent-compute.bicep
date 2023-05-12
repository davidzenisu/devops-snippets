/* 
az deployment group what-if `
--name azAgentDeyployment  `
--resource-group XXXXXXXXXXXXXXXXXXXXXX  `
--template-file agent-compute.bicep `
--parameters `
acgName="XXXXXXXXXXXXXXXXXXXXXX" `
imageType="ubuntu2204" `
imageVersion="0.0.1" `
storageAccountName="XXXXXXXXXXXXXXXXXXXXXX" `
imgageUri="XXXXXXXXXXXXXXXXXXXXXX.vhd" `
adminUsername="azureuser" `
adminPublicKey="ssh-rsa XXXXXXXXXXXXXXXXXXXXXX" `
adminPrivateKey64="XXXXXXXXXXXXXXXXXXXXXX" `
keyVaultName="XXXXXXXXXXXXXXXXXXXXXX" `
deployKeyVault=false `
objectId="XXXXXXXXXXXXXXXXXXXXXX" `
vnetResourceGroupName="XXXXXXXXXXXXXXXXXXXXXX" `
virtualNetworkName="XXXXXXXXXXXXXXXXXXXXXX" `
subnetName="XXXXXXXXXXXXXXXXXXXXXX" 
*/

/*
az deployment group what-if `
--name azAgentDeyployment  `
--resource-group XXXXXXXXXXXXXXXXXXXXXX  `
--template-file agent-compute.bicep `
--parameters `
usePredefinedImage=true `
imageType="ubuntuXS" `
adminUsername="XXXXXXXXXXXXXXXXXXXXXX" `
adminPublicKey="ssh-rsa XXXXXXXXXXXXXXXXXXXXXX" `
adminPrivateKey64="XXXXXXXXXXXXXXXXXXXXXX" `
keyVaultName="XXXXXXXXXXXXXXXXXXXXXX" `
deployKeyVault=false `
objectId="XXXXXXXXXXXXXXXXXXXXXX" `
vnetResourceGroupName="XXXXXXXXXXXXXXXXXXXXXX" `
virtualNetworkName="XXXXXXXXXXXXXXXXXXXXXX" `
subnetName="XXXXXXXXXXXXXXXXXXXXXX" 
*/

// region: General Settings (1)
@description('Location for all resources.')
param deploymentLocation string = resourceGroup().location

// region: Image Settings (5)
@description('Name of the image type. Image, VMSS and key vault secret names will be inferred from this')
param imageType string
@description('Use predefined image. In this case all image settings except imageType will be ignored')
param usePredefinedImage bool = false
@description('Name of created Azure Compute Gallery.')
param acgName string = ''
@description('Number of created image version.')
param imageVersion string = '1.0.0'
@description('Name of storage account of vhd image file.')
param storageAccountName string = ''
@description('Uri of vhd image file.')
param imgageUri string = ''

// region: Authentication (5)
@description('Username for the Virtual Machine.')
param adminUsername string
@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
param adminPublicKey string = ''
@description('SSH Key Secret stored in key vault in base64 format (!!!). Linux agents only.')
@secure()
param adminPrivateKey64 string = ''
@description('Password for VM. Windows agents only.')
@secure()
param adminPassword string = ''
@description('Name of the deloyed Key vault. Linux agents only.')
param keyVaultName string
@description('Specifies the object ID of a user, service principal or security group. Should be the id of the DevOps service principal to have acces to the secret.')
param objectId string
@description('Boolean whether to (re)deploy key vault. Should be set to false for existing key vaults with modified access policies. For details see: https://stackoverflow.com/a/67850177/15610275')
param deployKeyVault bool = false

//region: Networking (3)
@description('Resource group name of existing VNET where VMSS will be deployed.')
param vnetResourceGroupName string
@description('Name of existing VNET where VMSS will be deployed.')
param virtualNetworkName string
@description('Name of existing subnet where VMSS will be deployed.')
param subnetName string

var vmssPrefix  = format('vm{0}{1}', substring(imageType, 0, 3), substring(guid(imageType, 'prefix'), 0, 4))
var imgName = 'vm-agent-${imageType}'
var vmssName = 'vmss-agent-${imageType}'
var secretName = '${vmssName}-key'
var osType = (contains(imageType, 'windows'))? 'Windows' : 'Linux'
var authenticationType = (contains(imageType, 'windows'))? 'password' : 'sshPublicKey'

module computeImage 'compute-image/template.bicep' = if (!usePredefinedImage) {
  name: 'azComputeImageVersionDeployment'
  params: {
    deploymentLocation: deploymentLocation
    acgName: acgName
    imgName: imgName
    osType: osType
    imgVersion: imageVersion
    storageAccountName: storageAccountName
    imgUri: imgageUri
  }
}

module vmms 'vmss/template.bicep' = {
  name: 'azVmssDeployment'
  params: {
    deploymentLocation: deploymentLocation
    name: vmssName
    vmssPrefix: vmssPrefix
    imageSku: 'Standard_D4s_v3'
    adminUsername: adminUsername
    adminPasswordOrKey: (authenticationType == 'password')? adminPassword : adminPublicKey
    authenticationType: authenticationType
    vnetResourceGroupName: vnetResourceGroupName
    virtualNetworkName: virtualNetworkName
    subnetName: subnetName
    imgId: usePredefinedImage? '' : computeImage.outputs.imgId
  }
  dependsOn: [
    computeImage
  ]
}

module keyVaultSecret 'keyvault-secret/template.bicep' = {
  name: 'azKeyVaultSecretDeployment'
  params: {
    deploymentLocation: deploymentLocation
    keyVaultName: keyVaultName
    objectId: objectId
    secretName: secretName
    secretValue: (authenticationType == 'password')? adminPassword : base64ToString(adminPrivateKey64)
    deployKeyVault: deployKeyVault
  }
}
