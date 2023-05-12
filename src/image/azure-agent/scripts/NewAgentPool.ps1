<#
    .SYNOPSIS
        A helper script to check if a specified agent pool exists on the azure devops organization.
    .DESCRIPTION
        Notice: Will require a context of some sort to be set. This can be achieved in pipeline by setting env:AZURE_DEVOPS_EXT_PAT
        See https://learn.microsoft.com/en-us/azure/devops/cli/log-in-via-pat
        Script to be used as part of Azure DevOps pipeline.
        May be refactored into module at one point.
    .PARAMETER AgentPoolName
        Name of created agent pool.
    .PARAMETER VmssName
        Name of Vmss that should be turned into an agent pool.
    .PARAMETER OsType
        Name of OS of the VMSS image. Windows or Linux.
    .PARAMETER ProjectId
        Id of the Azure DevOps project where the agent pool should be created.
    .PARAMETER OrganizationUrl
        Url of the Azure DevOps organization.
    .PARAMETER ServiceConnectionName
        Name of the Azure DevOps service connection.
    .PARAMETER ResourceGroupName
        Name of resource group of the VMSS hosting the agent pool.
    .PARAMETER TenantId
        Id of the tenant to log into. If none is provided will try to use the context currently assigned or log into the default tenant.
    .PARAMETER SubscriptionId
        Id of the subscription to log into. If none is provided will try to use the context currently assigned or set the default subscription.
    .PARAMETER SkipLogin
        Switch to skip check for currently set az cli context and simply accept the passed subscription id.
    .EXAMPLE
        TestAgentPool.ps1 -VmssName vmss-agent-ubuntu2204 -OsType "Linux" -ResourceGroupName XXXXXXXXXXXXXXXXXXXXXX -ProjectId $(System.TeamProjectId) -OrganizationUrl $(System.CollectionUri) -ServiceConnectionName $(serviceConnection)
#>
param (
    [Parameter(Mandatory = $True)]
    [string] $AgentPoolName,
    [Parameter(Mandatory = $True)]
    [string] $VmssName,
    [Parameter(Mandatory = $True)]
    [string] $OsType,
    [Parameter(Mandatory = $True)]
    [string] $ProjectId,
    [Parameter(Mandatory = $True)]
    [string] $OrganizationUrl,
    [Parameter(Mandatory = $True)]
    [string] $ServiceConnectionName,
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

$serviceConnectionList = (az devops service-endpoint list --query "[?type=='azurerm']") | ConvertFrom-Json
$currentServiceConnection = $serviceConnectionList | Where-Object -FilterScript {$_.name -eq $ServiceConnectionName}
Write-Host "##[command] Found service connection id $($currentServiceConnection.id)"

$agentCreationRequestBody = @{
    serviceEndpointId = "$($currentServiceConnection.id)"
    serviceEndpointScope = "$ProjectId"
    azureId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/virtualMachineScaleSets/$VmssName"
    maxCapacity = 12
    desiredIdle = 0
    recycleAfterEachUse = $False
    maxSavedNodeCount = 0
    osType = "$OsType"
    desiredSize = 1
    agentInteractiveUI = $False
    timeToLiveMinutes = 30
}

Write-Host "##[command] Creating request file: $($agentCreationRequestBody | ConvertTo-Json)"
$agentCreationRequestFile = "./agentCreationRequestBody.json"
$agentCreationRequestBody  | ConvertTo-Json | Out-File $agentCreationRequestFile

Write-Host "##[command] Creating agent pool $AgentPoolName"

az devops invoke `
    --area distributedtask `
    --resource elasticpools `
    --api-version 7.0 `
    --http-method Post `
    --query-parameters `
        poolName=$AgentPoolName `
        authorizeAllPipelines=true `
        autoProvisionProjectPools=true `
    --in-file $agentCreationRequestFile  
$agentCreationSuccess=[bool]($LASTEXITCODE -eq 0)
Remove-Item $agentCreationRequestFile -Force
Write-Host "##vso[task.setvariable variable=AgentPoolCreated;isoutput=true]$agentCreationSuccess"
if ($agentCreationSuccess) {
    Write-Host "##[command] Agent pool $AgentPoolName was created successfully."
}
else {
    throw "##[command] Agent pool $AgentPoolName could not be created!"
}
return $agentCreationSuccess