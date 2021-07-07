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
    Initialize a S3 bucket for storing the Restic repository.
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
    Write-Information "+ Ensuring S3 buckets exists."

    . (Join-Path $PSScriptRoot 'Shared-ResticS3.ps1')
}

process {
    $mountItem = [ResticDockerCmdArgs]::new(
        $MountSource,
        $AccessKey,
        $SecretKey,
        $ServerUrl,
        $(Join-Path $PSScriptRoot $ResticPath -Resolve),
        $ResticCaCertFileName,
        $ResticRepoPassword
    )
    
    [string]$mountName = $mountItem.MountSource
    [string]$bucketName = FormatS3BucketName($mountName)

    [string[]]$snapshotArgs = $mountItem.CreateResticDockerCmdArgs($bucketName, @(
        'snapshots', '--host', $mountName
    ))
    $null = & docker $snapshotArgs

    if ($LastExitCode -ne 0) {
        [string[]]$initArgs = $mountItem.CreateResticDockerCmdArgs($bucketName, @(
            'init'
        ))
        Write-Information "Initializing S3 bucket $bucketName"
        $null = & docker $initArgs
    }

    $detail = [PSCustomObject](@{} + $PSBoundParameters)
    $detail
}

end {
}
