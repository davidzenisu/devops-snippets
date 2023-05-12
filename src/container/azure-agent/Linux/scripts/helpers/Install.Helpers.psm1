function Get-ToolsetContent {
    $toolset = Join-Path $env:SCRIPT_PATH "toolset.json"
    Get-Content $toolset -Raw | ConvertFrom-Json
}

function Get-ToolsetValue {
    param (
        [Parameter(Mandatory = $true)]
        [string] $KeyPath
    )

    $jsonNode = Get-ToolsetContent

    $pathParts = $KeyPath.Split(".")
    # try to walk through all arguments consequentially to resolve specific json node
    $pathParts | ForEach-Object {
        $jsonNode = $jsonNode.$_
    }
    return $jsonNode
}