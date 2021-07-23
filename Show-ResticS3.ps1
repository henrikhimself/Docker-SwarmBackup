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
    Show snapshots in a Restic respository.
    .DESCRIPTION
    .PARAMETER ServiceId
    .PARAMETER MountSource
    .PARAMETER AccessKey
    .PARAMETER SecretKey
    .PARAMETER ServerUrl
    .PARAMETER ResticPath
    .PARAMETER ResticCaCertFileName
    .PARAMETER ResticRepoPassword
#>
#requires -Version 7
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$ServiceId,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$MountSource,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$AccessKey,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$SecretKey,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$ServerUrl,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$ResticPath,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$ResticCaCertFileName,

    # ToDo: Secure password value
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$ResticRepoPassword
)

begin {
    Set-StrictMode -Version Latest
    $InformationPreference = 'Continue'
    Write-Information "+ Listing Restic snapshots."

    . (Join-Path $PSScriptRoot 'Shared.ps1')
}

process {
    $mountItem = [ResticDockerCmdArgs]::new(
        $MountSource,
        $AccessKey,
        $SecretKey,
        $ServerUrl,
        $ResticPath,
        $ResticCaCertFileName,
        $ResticRepoPassword
    )
    
    [string]$mountName = $mountItem.MountSource
    [string]$bucketName = FormatS3BucketName($mountName)

    [string[]]$snapshotArgs = $mountItem.CreateResticDockerCmdArgs($bucketName, @(
        'snapshots', '--host', $mountName
    ))
    & docker $snapshotArgs
}

end {
}
