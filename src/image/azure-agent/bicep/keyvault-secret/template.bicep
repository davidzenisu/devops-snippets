/* 
az deployment group what-if `
--name keyVaultDeployment  `
--resource-group XXXXXXXXXXXXXXXXXXXXXX  `
--template-file azure-keyvault-secret.bicep `
--parameters `
keyVaultName="XXXXXXXXXXXXXXXXXXXXXX" `
objectId="XXXXXXXXXXXXXXXXXXXXXX" `
secretName="XXXXXXXXXXXXXXXXXXXXXX" `
secretValue="XXXXXXXXXXXXXXXXXXXXXX"
*/

@description('Location for all resources.')
param deploymentLocation string = resourceGroup().location
@description('Name of the deloyed Key vault.')
param keyVaultName string
@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'
@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant.')
param objectId string = ''
@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
  'all'
]
@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'all'
]
@description('Name of the deloyed secret.')
param secretName string
@description('Value of the deloyed secret.')
@secure()
param secretValue string
@description('Boolean whether to (re)deploy key vault. Should be set to false for existing key vaults with modified access policies. For details see: https://stackoverflow.com/a/67850177/15610275')
param deployKeyVault bool = false

var tenantId = subscription().tenantId

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = if (deployKeyVault) {
  name: keyVaultName
  location: deploymentLocation
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    tenantId: tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}




resource accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  parent: kv
  name: 'add'
  properties: {
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
        }
      }
    ]
  }
}


resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: kv
  name: secretName
  properties: {
    value: secretValue
  }
}
