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
    Retrieves file list from a volume.
    .DESCRIPTION

    .PARAMETER MountDetail
#>
#requires -Version 7
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [object]$MountDetail
)

begin {
    Set-StrictMode -Version Latest
    $InformationPreference = 'Continue'
    Write-Information "+ Retrieving volume file list."

    . (Join-Path $PSScriptRoot 'Shared.ps1')
}

process {
    $PwshDockerCmdArgs = [PwshDockerCmdArgs]::new()

    [string]$mountName = $MountDetail.MountSource
    [string[]]$dockerArgs = $PwshDockerCmdArgs.CreatePwshDockerCmdArgs($mountName, 'volumeData', @(
        'pwsh', '-Command', 'Get-ChildItem', '-Path', '/volumeData', '|', 'ConvertTo-Json'
    ))

    [string]$dockerOutput = & docker $dockerArgs
    $dockerOutput = StripAnsiCharacters($dockerOutput)
    
    [PSCustomObject]$fileList = $dockerOutput | ConvertFrom-Json
    $fileList
}

end {
}