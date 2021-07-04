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