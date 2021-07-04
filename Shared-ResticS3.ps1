#requires -Version 7

Function FormatS3BucketName([string]$name) {
    [string]$bucketName = $name.ToLower().PadRight(3, '-') -replace('/', '.') -replace('_', '-') -replace '[^a-z0-9\.-]'
    if ($bucketName.length -gt 63) {
        throw "Generated bucket name is longer than 63 character"
    }
    return $bucketName
}

Class ItemsById : System.Collections.Hashtable {
    [void] Add([string]$id, $data) {
        if (!$this.ContainsKey($id)) {
            $this[$id] = [System.Collections.ArrayList]::new()
        }
        $null = $this[$id].Add($data)
    }
}

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
                '--cacert', "/restic/certs/$resticCaCertFileName"
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

Class PwshDockerCmdArgs {
    [string[]]$dockerArgs
    [string[]]$appArgs

    PwshDockerCmdArgs (
    ) {
        $this.dockerArgs = @(
            'run', '--rm'
        )
        $this.appArgs = @(
            'mcr.microsoft.com/powershell:lts-debian-buster-slim'
        )
    }

    [string[]]CreatePwshDockerCmdArgs (
        [string]$mountSource,
        [string]$bucketName,
        [string[]]$cmdArgs
    ) {
        [string[]]$argumentList = $this.dockerArgs 
        $argumentList += @(
            '--mount', "type=volume,source=$mountSource,target=/$bucketName"
        )
        $argumentList += $this.appArgs
        $argumentList += $cmdArgs
        return $argumentList
    }
}
