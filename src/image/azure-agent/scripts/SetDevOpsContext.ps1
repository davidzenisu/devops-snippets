<#
    .SYNOPSIS
        A helper script to set the correct context to call Azure DevOps APIs through Azure CLI.
    .DESCRIPTION
        See https://learn.microsoft.com/en-us/azure/devops/cli/log-in-via-pat
        Script to be used as part of Azure DevOps pipeline.
        May be refactored into module at one point.
    .PARAMETER ProjectId
        Id of the Azure DevOps project where the agent pool should be created.
    .PARAMETER OrganizationUrl
        Url of the Azure DevOps organization.
    .EXAMPLE
        SetDevOpsAccessToken.ps1 -ProjectId $(System.TeamProjectId) -OrganizationUrl $(System.CollectionUri)
#>

Write-Host "##[command] Checking if custom access token is set."
# workaround: if variable doesn't exist, the literal value is taken instead
if ($env:CUSTOM_PAT -and $env:CUSTOM_PAT -ne '$(CustomAccessToken)') {
    Write-Host "##[command] Found access token $env:CUSTOM_PAT"
    Write-Host "##[command] Overwriting current token with custom token!"
    $env:AZURE_DEVOPS_EXT_PAT = $env:CUSTOM_PAT
}

if (!$env:AZURE_DEVOPS_EXT_PAT) {
    $errorMessage = "No access token set for az DevOps CLI access."
    Write-Host "##[error] $errorMessage Exiting script..."
    throw $errorMessage;
}

az devops configure -d organization="$OrganizationUrl"
az devops configure -d project="$ProjectId"