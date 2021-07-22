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
    Restore a snapshot from Restic into a volume.
    .DESCRIPTION
    .PARAMETER ServiceId
    .PARAMETER MountSource
    .PARAMETER AccessKey
    .PARAMETER SecretKey
    .PARAMETER ServerUrl
    .PARAMETER ResticPath
    .PARAMETER ResticCaCertFileName
    .PARAMETER ResticRepoPassword
    .PARAMETER ResticSnapshotId
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
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [string]$ResticRepoPassword,

    [Parameter(Mandatory = $false)]
    [string]$ResticSnapshotId = 'a45df5d1'
)

begin {
    Set-StrictMode -Version Latest
    $InformationPreference = 'Continue'
    Write-Information "+ Starting restore."

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
    $PwshDockerCmdArgs = [PwshDockerCmdArgs]::new()

    foreach ($id in $MountItemsById.Keys) {
        [PSCustomObject]$service = & docker @('service', 'inspect', $id) | ConvertFrom-Json
        [int]$replicaCount = $service.Spec.Mode.Replicated.Replicas

        Write-Information "--- Processing service $($service.Spec.Name)."
        try {
            # if ($replicaCount -gt 0) {
            #     & docker @('service', 'scale', "$id=0")
            # }

            [ResticDockerCmdArgs[]]$mountItems = $MountItemsById[$id]

            foreach ($mountItem in $mountItems) {
                [string]$mountName = $mountItem.MountSource
                [string]$bucketName = FormatS3BucketName($mountName)
                Write-Information "Restoring volume $mountName from S3 bucket $bucketName"
                
                # ToDo: Restore content from S3 into volume
                
            }
        } finally {
            # if ($replicaCount -gt 0) {
            #     & docker service scale $("$id=$replicaCount")
            # }
        }
    }
}