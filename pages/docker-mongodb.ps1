Add-PodeWebPage -Name 'Workflow' -Title 'Workflow: Docker -> Container -> MongoDB -> Docker' -Icon 'database' -ScriptBlock {
    
    # set the home page controls
    New-PodeWebAccordion -Bellows @(

        New-PodeWebBellow -Name 'Start Docker Desktop' -Content @(

            $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
            if([String]::IsNullOrEmpty($isrunning)){
                $isrunning = $false
            }else{
                $isrunning = $true
            }

            New-PodeWebForm -Name 'Start Docker' -ScriptBlock {
        
                if(-not($isrunning)){
                    Start-Process -FilePath "$($env:ProgramFiles)\Docker\Docker\Docker Desktop.exe" -WindowStyle Minimized -NoNewWindow
                    do {
                        Start-Sleep -Seconds 5
                        $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
                    }
                    while ($isrunning.count -lt 5)
                    Start-Sleep -Seconds 10
                    'Docker Desktop started' | Out-PodeWebTextbox 
                }
                Move-PodeWebAccordion -Name 'Start Docker Container'

            } -Content @(
                $Options = @('Start Docker Desktop')
                if($isrunning){
                    New-PodeWebCheckbox -Name 'Start Docker' -Options $Options -AsSwitch -Checked
                }else{
                    New-PodeWebCheckbox -Name 'Start Docker' -Options $Options -AsSwitch
                }
            )

        )

        New-PodeWebBellow -Name 'Start Docker Container' -Content @(

            $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
            if([String]::IsNullOrEmpty($isrunning)){
                $isrunning = $false
            }else{
                $isrunning = $true
            }

            New-PodeWebForm -Name 'Container' -ScriptBlock {
                $Modules = $WebEvent.Data['Container']
                foreach($item in ($Modules -split ',')){
                    docker start $item
                    $data = docker container inspect $item --format 'Up: {{.Config.Hostname}}, StartedAt: {{.State.StartedAt}}, State: {{.State.Status}}'
                    $data | Out-PodeWebTextbox
                    Move-PodeWebAccordion -Name 'Stop Docker Desktop'
                }
            } -Content @(
                if($isrunning){
                    $Options = @(docker container ls -a --format "{{.Names}}")
                }else{
                    $Options = 'Docker Desktop not running!'
                }
                New-PodeWebCheckbox -Name 'Container' -Options $Options -AsSwitch

            )
        )

        New-PodeWebBellow -Name 'Stop Docker Desktop' -Content @(

            $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
            if([String]::IsNullOrEmpty($isrunning)){
                $isrunning = $false
            }else{
                $isrunning = $true
            }
    
            New-PodeWebForm -Name 'Stop Docker' -ScriptBlock {
                $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
                if ($isrunning) {
                    $data = docker stop $(docker ps -q)
                    $isrunning.CloseMainWindow()
                    $isrunning | Stop-Process -Force
                }
                do {
                    Start-Sleep -Seconds 5
                    $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
                }
                while (-not([String]::IsNullOrEmpty($isrunning)))
                'Docker Desktop stopped' | Out-PodeWebTextbox
            } -Content @(
                $Options = @('Stop Docker Desktop')
                if($isrunning){
                    New-PodeWebCheckbox -Name 'Stop Docker' -Options $Options -AsSwitch -Checked
                }else{
                    New-PodeWebCheckbox -Name 'Stop Docker' -Options $Options -AsSwitch
                }
            )

        )

    )    

}