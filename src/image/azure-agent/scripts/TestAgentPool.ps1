<#
    .SYNOPSIS
        A helper script to check if a specified agent pool exists on the azure devops organization.
    .DESCRIPTION
        Notice: Will require a context of some sort to be set. This can be achieved in pipeline by setting env:AZURE_DEVOPS_EXT_PAT
        See https://learn.microsoft.com/en-us/azure/devops/cli/log-in-via-pat
        Script to be used as part of Azure DevOps pipeline.
        May be refactored into module at one point.
    .PARAMETER VmssName
        Name of Vmss to search for.
    .PARAMETER ProjectId
        Id of the Azure DevOps project where the agent pool should be created.
    .PARAMETER OrganizationUrl
        Url of the Azure DevOps organization.
    .PARAMETER ResourceGroupName
        Name of resource group to search in.
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
    [string] $VmssName,
    [Parameter(Mandatory = $True)]
    [string] $ProjectId,
    [Parameter(Mandatory = $True)]
    [string] $OrganizationUrl,
    [Parameter(Mandatory = $True)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory = $False)]
    [string] $TenantId,
    [Parameter(Mandatory = $False)]
    [string] $SubscriptionId,
    [Parameter(Mandatory = $False)]
    [switch] $SkipLogin
)
$SubscriptionId = ($SkipLogin)? $SubscriptionId : (./SetAzContext.ps1 -TenantId $TenantId -SubscriptionId $SubscriptionId)
./SetDevOpsContext.ps1 -ProjectId "$ProjectId" -OrganizationUrl "$OrganizationUrl"
$agentPoolList = (az devops invoke --area distributedtask --resource elasticpools --api-version 7.0) | ConvertFrom-Json
Write-Host "##[command] Found $($agentPoolList.value.length) agent pools."
Write-Host "##[command] Searching for agent pool $VmssName."
$currentAgentPool = $agentPoolList.value | Where-Object -FilterScript {$_.azureId -eq "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/virtualMachineScaleSets/$VmssName"}
if ($currentAgentPool) {
    Write-Host "##[command] Found existing agent pool $($currentAgentPool.azureId)."
} else {
    Write-Host "##[command] Found no agent pool."
}
$agentPoolExists = [bool]($currentAgentPool)
Write-Host "##vso[task.setvariable variable=AgentPoolExists;isoutput=true]$agentPoolExists"
return $agentPoolExists