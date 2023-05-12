<#
    .SYNOPSIS
        A helper script to find a generated packer image file on a specified resource group.
    .DESCRIPTION
        Script to be used as part of Azure DevOps pipeline.
        May be refactored into module at one point.
    .PARAMETER ImageType
        Name of image type. Resource group name will be based on that.
    .PARAMETER TenantId
        Id of the tenant to log into. If none is provided will try to use the context currently assigned or log into the default tenant.
    .PARAMETER SubscriptionId
        Id of the subscription to log into. If none is provided will try to use the context currently assigned or set the default subscription.
    .PARAMETER SkipLogin
        Switch to skip check for currently set az cli context and simply accept the passed subscription id.
    .EXAMPLE
        FindPackerImageFile.ps1 -ImageType Ubuntu2204
#>
param (
    [Parameter(Mandatory = $True)]
    [string] $ImageType,
    [Parameter(Mandatory = $False)]
    [string] $TenantId,
    [Parameter(Mandatory = $False)]
    [string] $SubscriptionId,
    [Parameter(Mandatory = $False)]
    [switch] $SkipLogin
)

$SubscriptionId = ($SkipLogin)? $SubscriptionId : (./SetAzContext.ps1 -TenantId $TenantId -SubscriptionId $SubscriptionId)
Write-Host "##[command] Check if vhd was successfully created"

$ResourceGroupName = (./GetPackerResourceGroup.ps1 -ImageType $ImageType)

$tempStorageAccount = (az resource list --resource-group $ResourceGroupName --query "[?type=='Microsoft.Storage/storageAccounts']") | ConvertFrom-Json
if ($tempStorageAccount.length -ne 1) {
  throw "Number of found storage accounts in ${ResourceGroupName}: $($tempStorageAccount.length). Expected amount: 1."
}
Write-Host "##[command] Searching for vhd image in storage account (may install storage-preview extension)"
az config set extension.use_dynamic_install=yes_without_prompt
# the next line is pretty stupid but it might be useful in the future
$container =az storage container list --account-name $tempStorageAccount.name --query "[?name == 'system'] | @[0]" | ConvertFrom-Json
$vhdFile = az storage blob list --account-name $tempStorageAccount.name -c $($container.name) --query "[?ends_with(name, '.vhd')]" | ConvertFrom-Json
if ($vhdFile.length -ne 1) {
  throw "Number of vhd artifacts in storage accounts $($tempStorageAccount.name):  $($vhdFile.length). Expected amount: 1."
}

# pattern: https://my_storageaccount_name.blob.core.windows.net/my_container_name/my_file_name
$packerImageVhd = "https://$($tempStorageAccount.name).blob.core.windows.net/$($container.name)/$($vhdFile.name)"

Write-Host "##[command] Found vhd image at $packerImageVhd."
Write-Host "##vso[task.setvariable variable=PackerImageVhd;isoutput=true]$packerImageVhd"
Write-Host "##[command] Found storage account $($tempStorageAccount.name)."
Write-Host "##vso[task.setvariable variable=PackerImageStorageAccount;isoutput=true]$($tempStorageAccount.name)"
return $packerImageVhd