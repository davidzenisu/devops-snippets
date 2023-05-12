<#
    .SYNOPSIS
        A helper script to modify the packer config file to disable Microsoft Defender.
    .DESCRIPTION
        Script that uses the passed path to the packer config file to add a tag to the VM used to create the image.
        Thet tag disables automatically provisioning Microsoft Defender to the VM which prevents the image from being created successfully.
        For details see: https://github.com/actions/runner-images/discussions/6251
    .PARAMETER PackerConfigFilePath
        Path to packer config json file. hcl format is currently not supported!
    .EXAMPLE
        AddExcludeMdeAutoProvisioningTag.ps1 -PackerConfigFile '$(System.DefaultWorkingDirectory)/packer-config.json'
#>
param (
    [Parameter(Mandatory = $True)]
    [string] $PackerConfigFilePath
)

Write-Host "##[command] Fetching image definition from $PackerConfigFilePath"
$packerConfigFile = Get-Content "$PackerConfigFilePath" -raw | ConvertFrom-Json
$azureTagObject =@{
    "ExcludeMdeAutoProvisioning" = "True"
}
$packerConfigFile.builders | Add-Member -MemberType noteproperty -Name azure_tags -Value $azureTagObject
Write-Host "##[command] Saving updated image definition"
$packerConfigFile | ConvertTo-Json -depth 32| set-content "$PackerConfigFilePath"
Write-Host "##[command] Udated image definition successfully!"