<#
    .SYNOPSIS
        A helper script to set the next image version. Will automatically bump build version by default.
    .DESCRIPTION
        Script to be used as part of Azure DevOps pipeline.
        May be refactored into module at one point.
    .PARAMETER ResourceGroupName
        Name of resource group to search in.
    .PARAMETER GalleryName
       Name of gallery to search in.
    .PARAMETER ImageName
       Name of image to search in.
    .PARAMETER TenantId
        Id of the tenant to log into. If none is provided will try to use the context currently assigned or log into the default tenant.
    .PARAMETER SubscriptionId
        Id of the subscription to log into. If none is provided will try to use the context currently assigned or set the default subscription.
    .PARAMETER SkipLogin
        Switch to skip check for currently set az cli context and simply accept the passed subscription id.
    .EXAMPLE
        TestAgentPool.ps1 -VmssName vmss-agent-ubuntu2204 -ResourceGroupName XXXXXXXXXXXXXXXXXXXXXX
#>
param (
    [Parameter(Mandatory = $True)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory = $True)]
    [string] $GalleryName,
    [Parameter(Mandatory = $True)]
    [string] $ImageName,
    [Parameter(Mandatory = $False)]
    [string] $TenantId,
    [Parameter(Mandatory = $False)]
    [string] $SubscriptionId,
    [Parameter(Mandatory = $False)]
    [switch] $SkipLogin
)
$SubscriptionId = ($SkipLogin)? $SubscriptionId : (./SetAzContext.ps1 -TenantId $TenantId -SubscriptionId $SubscriptionId)

Write-Host "##[command] Checking if image version of $ImageName exists"
$azImageVersions = (az sig image-version list --resource-group "$ResourceGroupName" --gallery-name "$GalleryName" --gallery-image-definition "$ImageName" --query "reverse(sort_by([].{Name: name}, &Name))") | ConvertFrom-Json

if ($azImageVersions.length -gt 0) {
    $latestAzImageVersion = $azImageVersions[0].Name
    Write-Host "##[command] Found latest version $latestAzImageVersion"
    $newAzImageVersion = [System.Version]"$latestAzImageVersion" | ForEach-Object {"$($_.Major).$($_.Minor).$($_.Build+1)"}
    Write-Host "##[command] Increasing new version to $newAzImageVersion"
} else {
    $newAzImageVersion = "1.0.0"
    Write-Host "##[command] No image version found, setting version $newAzImageVersion"
}

Write-Host "##vso[task.setvariable variable=PackerImageVersion;isoutput=true]$newAzImageVersion"
return $newAzImageVersion