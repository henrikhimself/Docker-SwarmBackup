#requires -Version 7
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [object]$MountDetail
)

begin {
    Set-StrictMode -Version Latest
    $InformationPreference = 'Continue'
    Write-Information "+ Adding configuration."

    [string]$configPath = Join-Path $PSScriptRoot 'configs/ResticS3.json'
    Write-Verbose "Reading configuration from $configPath"
    [PSCustomObject]$Config = $null
    if (Test-Path -Path $configPath -PathType Leaf) {
        $Config = Get-Content -Path $configPath | ConvertFrom-Json
    }
 }

 process {
    $mountDetailWithConfig = @{}

    foreach ($property in $MountDetail.PSObject.Properties) {
        [string]$propertyName = $property.Name
        $propertyValue = $property.Value
        $mountDetailWithConfig[$propertyName] = $propertyValue
    }
    
    if ($Config) {
        foreach ($property in $Config.PSObject.Properties) {
            [string]$propertyName = $property.Name
            $propertyValue = $property.Value
            $mountDetailWithConfig[$propertyName] = $propertyValue
        }
    }

    [PSCustomObject]$mountDetailWithConfig
}

end {
}