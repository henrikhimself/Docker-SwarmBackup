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
    Backup a volume to a Restic repository.
    .DESCRIPTION
    .PARAMETER ServiceId
    .PARAMETER MountSource
    .PARAMETER AccessKey
    .PARAMETER SecretKey
    .PARAMETER ServerUrl
    .PARAMETER ResticPath
    .PARAMETER ResticCaCertFileName
    .PARAMETER ResticRepoPassword
    .PARAMETER BucketNamePrefix
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
    [string]$ResticRepoPassword,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$BucketNamePrefix
)

begin {
    Set-StrictMode -Version Latest
    $InformationPreference = 'Continue'
    Write-Information "+ Starting backup."

    . (Join-Path $PSScriptRoot 'Shared.ps1')
    $MountItemsById = [ItemsById]::new()
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
    $MountItemsById.Add($ServiceId, $mountItem)
}

end {
    foreach ($id in $MountItemsById.Keys) {
        [PSCustomObject]$service = & docker @('service', 'inspect', $id) | ConvertFrom-Json
        [int]$replicaCount = $service.Spec.Mode.Replicated.Replicas

        Write-Information "--- Processing service $($service.Spec.Name)."
        try {
            if ($replicaCount -gt 0) {
                & docker @('service', 'scale', "$id=0")
            }

            [ResticDockerCmdArgs[]]$mountItems = $MountItemsById[$id]

            foreach ($mountItem in $mountItems) {
                [string]$mountName = $mountItem.MountSource
                [string]$bucketName = FormatS3BucketName($BucketNamePrefix + $mountName)
                Write-Information "Backing up volume $mountName to S3 bucket $bucketName"

                $backupArgs = $mountItem.CreateResticDockerCmdArgs($bucketName, @(
                    'backup', '--host', $mountName, "/$bucketName"
                ))
                & docker $backupArgs
            }
        } finally {
            if ($replicaCount -gt 0) {
                & docker @('service', 'scale', "$id=$replicaCount")
            }
        }
    }
}