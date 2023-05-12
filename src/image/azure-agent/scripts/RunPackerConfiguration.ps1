<#
    .SYNOPSIS
        A helper script to run packer with a specific configuration to create an agent image.
    .DESCRIPTION
        Script that runs the GenerateResourcesAndImage function to generate images based on Microsoft's hosted agents.
        It loads the function from the module in .\helpers\GenerateResourcesAndImage.ps1.
        For details see: https://github.com/actions/runner-images/blob/main/docs/create-image-and-azure-resources.md
    .PARAMETER ImageType
        Type of image to create (OS and version).
    .PARAMETER AzureLocation
        Name of Azure Location where the image will be created.
    .PARAMETER ImageGenerationRepositoryRoot
        Root location of the github repository actions/runner-images. Defaults to working directory if left empty.
    .PARAMETER AzureClientId
       Client id needs to be provided for optional authentication via service principal.
    .PARAMETER AzureClientSecret
       Client secret needs to be provided for optional authentication via service principal.
    .PARAMETER TenantId
        Id of the tenant to log into. If none is provided will try to use the context currently assigned or log into the default tenant.
    .PARAMETER SubscriptionId
        Id of the subscription to log into. If none is provided will try to use the context currently assigned or set the default subscription.
    .PARAMETER ManualLogin
        Flag to enable manual login to replace current Azure context.
    .EXAMPLE
        AddExcludeMdeAutoProvisioningTag.ps1 -ImageType Ubuntu2204 -AzureLocation "eastus" -ImageGenerationRepositoryRoot $(System.DefaultWorkingDirectory)/runner-images
#>
param (
    [Parameter(Mandatory = $True)]
    [string] $ImageType,
    [Parameter(Mandatory = $True)]
    [string] $AzureLocation,
    [Parameter(Mandatory = $False)]
    [string] $ImageGenerationRepositoryRoot,
    [Parameter(Mandatory = $False)]
    [string] $AzureClientId,
    [Parameter(Mandatory = $False)]
    [string] $AzureClientSecret,
    [Parameter(Mandatory = $False)]
    [string] $TenantId,
    [Parameter(Mandatory = $False)]
    [string] $SubscriptionId,
    [Parameter(Mandatory = $False)]
    [bool] $ManualLogin = $False
)

$SubscriptionId = ($SkipLogin)? $SubscriptionId : (./SetAzContext.ps1 -TenantId $TenantId -SubscriptionId $SubscriptionId)
$azResourceGroup = (./GetPackerResourceGroup.ps1 -ImageType $ImageType)
$TenantId = (az account show | ConvertFrom-Json).tenantId
Write-Host Running packer image creation on subscription $TenantId
$ImageGenerationRepositoryRoot = [string]::IsNullOrEmpty($ImageGenerationRepositoryRoot)? "$pwd" : "$ImageGenerationRepositoryRoot"
Set-Location "$ImageGenerationRepositoryRoot"
# Manual login required, service principal not working at this point
if ($ManualLogin) {
    Write-Host  "##[command] Logging in manually."
   Connect-AzAccount -UseDeviceAuthentication -Tenant $TenantId
} else {
    Write-Host  "##[command] Using provided service connections with id $AzureClientId and secret $AzureClientSecret on tenant $TenantId."
}
Import-Module .\helpers\GenerateResourcesAndImage.ps1
GenerateResourcesAndImage `
  -SubscriptionId $subscriptionId  `
  -ResourceGroupName "$azResourceGroup"  `
  -ImageGenerationRepositoryRoot "$ImageGenerationRepositoryRoot"  `
  -ImageType "$ImageType"  `
  -AzureLocation "$AzureLocation" `
  -Force `
  -AzureClientId $AzureClientId `
  -AzureClientSecret $AzureClientSecret `
  -AzureTenantId $TenantId