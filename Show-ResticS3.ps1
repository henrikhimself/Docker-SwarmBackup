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
    & docker $snapshotArgs 2>$null
}

end {
}
