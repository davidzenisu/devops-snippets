<#
    .SYNOPSIS
        A helper script to remove the temporary resource group that was created to host the packer image vhd file.
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
        RemovePackerResourceGroup.ps1 -ImageType Ubuntu2204
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
$ResourceGroupName = (./GetPackerResourceGroup.ps1 -ImageType $ImageType)
Write-Host "##[command] Searching for temporary resource group $ResourceGroupName"
$groupExists = az group exists --name $ResourceGroupName
if ($groupExists -eq "true") {
    Write-Host "##[command] Remove temporary resource group $ResourceGroupName"
    az group delete --name $ResourceGroupName --yes | Out-Null
    Write-Host "##[command] Temporary group was deleted successfully"
} else {
    Write-Host "##[command] No temporary groups found"
}