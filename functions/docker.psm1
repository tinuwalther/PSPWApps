function Test-IsDockerRunning {
    [CmdletBinding()]
    param ()
    
    $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if([String]::IsNullOrEmpty($isrunning)){
        return $false
    }else{
        return $true
    }
}

function Test-IsContainerRunning {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$ContainerName
    )
    
    return (docker container ls -a --filter "Name=$($ContainerName)" --format "{{.Status}}")
}

function Start-DockerDesktop {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [Int]$Container = 1
    )

    Start-Process -FilePath "$($env:ProgramFiles)\Docker\Docker\Docker Desktop.exe" -NoNewWindow
    do {
        Start-Sleep -Seconds 5
        $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    }
    while ($isrunning.count -lt $Container)

}

function Start-DockerContainer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$ContainerName
    )

    $null = docker start $ContainerName
    $data = docker container inspect $ContainerName --format 'Up: {{.Config.Hostname}}, StartedAt: {{.State.StartedAt}}, State: {{.State.Status}}'
    return $data
}