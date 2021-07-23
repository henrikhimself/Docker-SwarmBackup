# Copyright 2021 Henrik Jensen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
<#  
    .SYNOPSIS
	Merges configuration from a file with the pipeline item.
    .DESCRIPTION
    This script will read in a configuration file and add properties from
    it onto the pipeline item before returning it.
    .PARAMETER MountDetail
    The item onto which the configuration is added.
    .PARAMETER ConfigFilePath
    Filepath of the configuration file to use.
#>
#requires -Version 7
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [object]$MountDetail,

    [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
    [string]$ConfigFilePath = (Join-Path $PSScriptRoot 'restic-example' | Join-Path -ChildPath 'Config.json')
)

begin {
    Set-StrictMode -Version Latest
    $InformationPreference = 'Continue'
    Write-Information "+ Adding configuration."

    Write-Verbose "Reading configuration from $ConfigFilePath"
    [PSCustomObject]$Config = $null
    if (Test-Path -Path $ConfigFilePath -PathType Leaf) {
        $Config = Get-Content -Path $ConfigFilePath | ConvertFrom-Json
    }
 }

 process {
    $mountDetailWithConfig = @{}

    # Add detail received in pipeline
    foreach ($property in $MountDetail.PSObject.Properties) {
        [string]$propertyName = $property.Name
        $propertyValue = $property.Value
        $mountDetailWithConfig[$propertyName] = $propertyValue
    }
    
    # Merge in detail read from config file
    if ($Config) {
        foreach ($property in $Config.PSObject.Properties) {
            [string]$propertyName = $property.Name
            $propertyValue = $property.Value
            $mountDetailWithConfig[$propertyName] = $propertyValue
        }
    }

    # Add magic defaults
    [string]$resticPath = $mountDetailWithConfig['ResticPath']
    if (!$resticPath) {
        $resticPath = $ConfigFilePath
    }
    if (!$resticPath.EndsWith([IO.Path]::PathSeparator)) {
        $resticPath = Split-Path -Path $resticPath
    }
    $mountDetailWithConfig['ResticPath'] = Resolve-Path -Path $resticPath
    
    [PSCustomObject]$mountDetailWithConfig
}

end {
}