/* 
az deployment group what-if `
--name computGalleryDeployment  `
--resource-group XXXXXXXXXXXXXXXXXXXXXX  `
--template-file azure-compute-image.bicep `
--parameters `
osType="Linux" `
acgName="XXXXXXXXXXXXXXXXXXXXXX" `
imgName="XXXXXXXXXXXXXXXXXXXXXX" `
imgVersion="0.1.0" `
storageAccountName="XXXXXXXXXXXXXXXXXXXXXX" `
imgUri="XXXXXXXXXXXXXXXXXXXXXX.vhd"
*/

@description('Location for all resources.')
param deploymentLocation string = resourceGroup().location
@description('Name of created Azure Compute Gallery.')
param acgName string
@description('Name of created compute image.')
param imgName string
@description('Operating system of the created image.')
@allowed([
  'Linux'
  'Windows'
])
param osType string
@description('Number of created image version.')
param imgVersion string = '1.0.0'
@description('Name of storage account of vhd image file.')
param storageAccountName string
@description('Uri of vhd image file.')
param imgUri string

resource azureComputeGallery 'Microsoft.Compute/galleries@2022-03-03' = {
  name: acgName
  location: deploymentLocation
  properties: {
    description: 'Azure Compute Gallery for images deployed as Azure DevOps agents.'
  }
}

resource azureComputeImage 'Microsoft.Compute/galleries/images@2022-03-03' = {
  name: imgName
  location: deploymentLocation
  parent: azureComputeGallery
  properties: {
    architecture: 'x64'
    hyperVGeneration: 'V1'
    identifier: {
      offer: 'DevOps'
      publisher: 'RIB'
      sku: imgName
    }
    osState: 'Generalized'
    osType: osType
  }
}

resource azureComputeImageVersion 'Microsoft.Compute/galleries/images/versions@2022-03-03' = {
  name: imgVersion
  location: deploymentLocation
  parent: azureComputeImage
  properties: {
    storageProfile: {
      osDiskImage: {
        hostCaching: 'ReadWrite'
        source: {
          id: resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
          uri: imgUri
        }
      }
    }
  }
}

output acgId string = azureComputeGallery.id
output imgId string = azureComputeImage.id
output imgVersionId string = azureComputeImageVersion.id
