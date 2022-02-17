Add-PodeWebPage -Group 'Docker' -Name '1. Docker Desktop' -Title 'Docker Desktop' -Icon 'docker' -ScriptBlock {

    $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if([String]::IsNullOrEmpty($isrunning)){
        $isrunning = 'not running'
    }else{
        $isrunning = 'running'
    }

    New-PodeWebCard -Name "Docker Desktop" -Content @(

        $array = @()
        $array += 'Choose...'
        if($isrunning -eq 'not running'){
            $array += 'Start Docker Desktop'
        }else{
            $array += 'Stop all Container'
            $array += 'Stop Docker Desktop'
        }
        
        New-PodeWebSelect -Name 'Action' -Options $array |
        Register-PodeWebEvent -Type Change -ScriptBlock {
            try{
                switch($WebEvent.Data.Action){
                    'Start Docker Desktop' {
                        Show-PodeWebToast -Message 'Start Docker Desktop, please wait...'
                        Start-Process -FilePath "$($env:ProgramFiles)\Docker\Docker\Docker Desktop.exe" -NoNewWindow
                        do {
                            Start-Sleep -Seconds 5
                            $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
                        }
                        while ($isrunning.count -lt 5)
                        Write-Host "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff')] Docker Desktop Process count $($isrunning.count)"
                        'Docker Desktop started' | Out-PodeWebTextbox
                        Write-Host "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff')] Docker Desktop started"
                    }
                    'Stop all Container'   {
                        $data = docker stop $(docker ps -q)
                        if($data){
                            "Container(s) $($data) stopped" | Out-PodeWebTextbox
                            Write-Host "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff')] Container(s) $($data) stopped"
                        }else{
                            "No running Container to stop" | Out-PodeWebTextbox
                        }
                    }
                    'Stop Docker Desktop'  {
                        $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
                        if ($isrunning) {
                            $isrunning.CloseMainWindow()
                            $isrunning | Stop-Process -Force
                        }
                        do {
                            Start-Sleep -Seconds 5
                            $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
                        }
                        while (-not([String]::IsNullOrEmpty($isrunning)))
                        'Docker Desktop stopped' | Out-PodeWebTextbox
                        Write-Host "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff')] Docker Desktop stopped"
                    }
                }
            }catch{
                New-PodeWebAlert -Type Warning -Value $($_.Exception.Message)
            }

        }   
    )

}
