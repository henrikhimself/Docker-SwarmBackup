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

Class ResticDockerCmdArgs {
    [string]$MountSource
    [string]$ServerUrl
    [string[]]$dockerArgs
    [string[]]$appArgs

    ResticDockerCmdArgs(
        [string]$mountSource,
        [string]$accessKey,
        [string]$secretKey,
        [string]$serverUrl,
        [string]$resticPath,
        [string]$resticCaCertFileName,
        [string]$resticRepoPasswd
    ) {
        $this.MountSource = $mountSource
        $this.ServerUrl = $serverUrl
        $this.dockerArgs = @(
            'run', '--rm',
            '--mount', "type=bind,source=$resticPath,target=/restic",
            '--env', 'RESTIC_CACHE_DIR=/restic/cache',
            '--env', "AWS_ACCESS_KEY_ID=$accessKey",
            '--env', "AWS_SECRET_ACCESS_KEY=$secretKey",
            '--env', "RESTIC_PASSWORD=$resticRepoPasswd")
        $this.appArgs = @(
            'restic/restic'
        )
        if ($resticCaCertFileName) {
            $this.appArgs += @(
                '--cacert', "/restic/$resticCaCertFileName"
            )
        }
    }

    [string[]] CreateResticDockerCmdArgs(
        [string]$bucketName,
        [string[]]$cmdArgs
    ) {
        [string[]]$argumentList = $this.dockerArgs 
        $argumentList += @(
            '--env', "RESTIC_REPOSITORY=s3:$($this.ServerUrl)/$bucketName",
            '--mount', "type=volume,source=$($this.MountSource),target=/$bucketName"
        )
        $argumentList += $this.appArgs
        $argumentList += $cmdArgs
        return $argumentList
    }
}
