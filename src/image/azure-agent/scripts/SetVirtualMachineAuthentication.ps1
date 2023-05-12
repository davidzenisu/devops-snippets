<#
    .SYNOPSIS
        A helper script to generate an ssh key that can later be used to create a VMSS and store the private key in a key vault.
    .DESCRIPTION
        Script to be used as part of Azure DevOps pipeline.
        May be refactored into module at one point.
    .PARAMETER SecretName
        Name of the secret that's checked.
    .PARAMETER KeyVaultName
        Name of the key vault that stores the authentication secret.
    .PARAMETER PasswordOnly
        Switch to only create password instead of ssh key.
    .PARAMETER TenantId
        Id of the tenant to log into. If none is provided will try to use the context currently assigned or log into the default tenant.
    .PARAMETER SubscriptionId
        Id of the subscription to log into. If none is provided will try to use the context currently assigned or set the default subscription.
    .PARAMETER SkipLogin
        Switch to skip check for currently set az cli context and simply accept the passed subscription id.
    .EXAMPLE
        SetVirtualMachineAuthentication -SecreName "secret1" -KeyVaultName "keyVault1" 
#>
param (
    [Parameter(Mandatory = $True)]
    [string] $SecretName,
    [Parameter(Mandatory = $True)]
    [string] $KeyVaultName,
    [Parameter(Mandatory = $False)]
    [switch] $PasswordOnly,
    [Parameter(Mandatory = $False)]
    [string] $TenantId,
    [Parameter(Mandatory = $False)]
    [string] $SubscriptionId,
    [Parameter(Mandatory = $False)]
    [switch] $SkipLogin
)
$SubscriptionId = ($SkipLogin)? $SubscriptionId : (./SetAzContext.ps1 -TenantId $TenantId -SubscriptionId $SubscriptionId)

Write-Host "##[command] Step 1/2: Check if a private key exists on key vault $KeyVaultName"
$secretValue = (az keyvault secret show --vault-name "$KeyVaultName" -n "$SecretName" | ConvertFrom-Json).value 

if($PasswordOnly) {
    Write-Host "##[command] Step 2/2: Creating password to upload to key vault and vm"
    if (!$secretValue) {
        $secretValue = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object {[char]$_})
    }
    Write-Host "##[command] Setting password for vmss configuration"
    Write-Host "##vso[task.setvariable variable=VirtualMachinePassword;issecret=true;isoutput=true]$secretValue"

    Write-Host "##[command] Unsetting ssh keys (not used)"
    Write-Host "##vso[task.setvariable variable=VirtualMachinePublicKey;isoutput=true]"
    Write-Host "##vso[task.setvariable variable=VirtualMachinePrivateKey;issecret=true;isoutput=true]"
    exit
}


Write-Host "##[command] Step 2/2: Creating ssh key to upload to key vault and vm"

$keyFile = "~/.ssh/id_rsa"

if(-not (test-path $keyFile)){
    New-Item -Path $keyFile -ItemType File -Force
}

if ($secretValue) {
    Out-File $keyFile -InputObject "$secretValue"
    chmod 600 $keyFile
} else {
    ECHO Y | ssh-keygen -q  -t rsa -b 4096 -N "" -f $keyFile 
}

$sshPublicKey=(ssh-keygen -y -f $keyFile)
$sshPrivateKey = (base64 -w 0 $keyFile)
Write-Host "##[command] Setting public key for vmss configuration"
Write-Host "##[command] Setting private key for key vault secret configuration (as base64 string)"
Write-Host "##vso[task.setvariable variable=VirtualMachinePublicKey;isoutput=true]$sshPublicKey"
Write-Host "##vso[task.setvariable variable=VirtualMachinePrivateKey;issecret=true;isoutput=true]$sshPrivateKey"
Write-Host "##[command] Unsetting password (not used)"
Write-Host "##vso[task.setvariable variable=VirtualMachinePassword;issecret=true;isoutput=true]"
Write-Host "##[command] Cleaning up by removing key files."
Remove-Item $keyFile -Force