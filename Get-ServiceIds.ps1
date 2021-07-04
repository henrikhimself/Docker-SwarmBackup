#requires -Version 7
[CmdletBinding()]
param(
)

begin {
    Set-StrictMode -Version Latest
    $InformationPreference = 'Continue'

    Write-Information "+ Getting service ids."
    [string[]]$IdList = & docker service ls --format '{{.ID}}'
}

process {
    foreach ($id in $IdList) {
        $id
    }
}

end {
}
