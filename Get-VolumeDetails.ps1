#requires -Version 7
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$ServiceId
)

begin {
    Set-StrictMode -Version Latest
    $InformationPreference = 'Continue'
    Write-Information "+ Getting mount sources."
}

process {
    [PSCustomObject]$service = & docker @('service', 'inspect', $ServiceId) | ConvertFrom-Json

    [PSCustomObject[]]$mounts = $service.Spec.TaskTemplate.ContainerSpec.Mounts
    foreach ($mount in $mounts) {
        if ($mount.Type -eq 'volume') {
            $mountDetail = [PSCustomObject]@{
                ServiceId = $service.ID
                MountType = $mount.Type
                MountSource = $mount.Source
                MountTarget = $mount.Target
            }
            $mountDetail
        }
    }
}

end {
}
