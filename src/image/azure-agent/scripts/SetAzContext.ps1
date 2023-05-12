<#
    .SYNOPSIS
        A helper script to check and/or set the current Azure CLI context and return the subscription id.
    .DESCRIPTION
        Script to be used as part of Azure DevOps pipeline.
        May be refactored into module at one point.
    .PARAMETER TenantId
        Id of the tenant to log into. If none is provided will try to use the context currently assigned or log into the default tenant.
    .PARAMETER SubscriptionId
        Id of the subscription to log into. If none is provided will try to use the context currently assigned or set the default subscription.
    .EXAMPLE
        SetAzContext.ps1
#>
param (
    [Parameter(Mandatory = $False)]
    [string] $TenantId,
    [Parameter(Mandatory = $False)]
    [string] $SubscriptionId
)

if (![string]::IsNullOrEmpty($TenantId) -and ![string]::IsNullOrEmpty($SubscriptionId)) {
    Write-Host "##[command] Logging in using the provided tenant ($TenantId) and subscription ($SubscriptionId)"
    az login --tenant $TenantId
    az account set --subscription $SubscriptionId
} else {
    Write-Host "##[command] No login information provided, using the current az context."
    $accountInfo = (az account show | ConvertFrom-Json)
    if (!$accountInfo) {
        Write-Host "##[command] No current az account context. Try logging in with default parameters."
        az login
        $accountInfo = (az account show | ConvertFrom-Json)
    }
    $TenantId = $accountInfo.tenantId
    $SubscriptionId = $accountInfo.id
}

Write-Host "##[command] Azure CLI context is set with subscription $SubscriptionId."
Write-Host "##vso[task.setvariable variable=SubscriptionId]$SubscriptionId"
return $SubscriptionId