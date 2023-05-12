<#
    .SYNOPSIS
        A helper script to create a name for the temporary resource group holding the vhd image file.
    .DESCRIPTION
        The script takes the name of an image type as an input and returns a resource group name.
    .PARAMETER ImageType
        Name of image type. Resource group name will be based on that.
    .EXAMPLE
        GetPackerResourceGroup.ps1 -ImageType Ubuntu2204
#>
param (
    [Parameter(Mandatory = $True)]
    [string] $ImageType
)

Write-Host "##[command] Generating resource group name for $ImageType."
$imageTypeUpperCase = "$ImageType".ToUpper()
$azResourceGroup = "RG-AZIMAGE-$imageTypeUpperCase-TEMP"
# Workaround for reserved word in resource names, see https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-reserved-resource-name
$azResourceGroup = $azResourceGroup.replace("WINDOWS", "WIN")
Write-Host "##[command] Returning resource group name $azResourceGroup."
return $azResourceGroup