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
