Add-PodeWebPage -Group 'Docker' -Name '2. Docker Container' -Title 'Docker Container' -Icon 'docker' -ScriptBlock {
    
    $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if([String]::IsNullOrEmpty($isrunning)){
        $isrunning = $false
    }else{
        $isrunning = $true
    }

    if($isrunning){
        New-PodeWebCard -Name 'Docker Container' -Content @(
        
            $array = @()
            $array += 'Choose a container to start...'
            $array += docker container ls -a --format "{{.Names}}" 
            
            New-PodeWebSelect -Name 'Start' -Size 5 -Options $array |
            Register-PodeWebEvent -Type Change -ScriptBlock {
                try{
                    $container_name = $($WebEvent.Data.'Start')
                    $start_container = docker start $container_name
                    Write-Host "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff')] Container $($start_container) started"
                    $data = docker container inspect $container_name --format 'Up: {{.Config.Hostname}}, StartedAt: {{.State.StartedAt}}, State: {{.State.Status}}'
                    $data | Out-PodeWebTextbox 
                }catch{
                    New-PodeWebAlert -Type Warning -Value $($_.Exception.Message)
                }
    
            }       
            
            $array1 = @()
            $array1 += 'Choose a container to stop...'
            $array1 += docker container ls --format "{{.Names}}"
            
            New-PodeWebSelect -Name 'Stop' -Size 5 -Options $array1 |
            Register-PodeWebEvent -Type Change -ScriptBlock {
                try{
                    $container_name = $($WebEvent.Data.'Stop')
                    $stop_container = docker stop $container_name
                    Write-Host "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff')] Container $($stop_container) stopped"
                    "Container $($container_name) stopped." | Out-PodeWebTextbox
                }catch{
                    New-PodeWebAlert -Type Warning -Value $($_.Exception.Message)
                }
    
            }   
            
        )

        New-PodeWebCard -Name 'Containers' -Content @(
            $container = docker container ls -a --format "Name: {{.Names}}, Status: {{.Status}}, Port-Mapping: {{.Ports}}"
            foreach($item in $container){
                New-PodeWebText -Value "$($item)" -InParagraph
            }
        )  

    }else{
        New-PodeWebCard -Name 'Docker Container' -Content @(
            New-PodeWebText -Value "Docker Desktop is not running, please start Docker Desktop" -InParagraph
        )
    }
}
