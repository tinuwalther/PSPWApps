Add-PodeWebPage -Group 'MssqlDB' -Name 'MSSQL InventoryDB' -Title 'MSSQL Inventory' -Icon 'database' -ScriptBlock {

    $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if([String]::IsNullOrEmpty($isrunning)){
        $isrunning = $false
        New-PodeWebCard -Name "Docker Container" -Content @(
            New-PodeWebText -Value "Docker Desktop is not running, please start Docker Desktop" -InParagraph
        )
    }else{
        $isrunning = $true
        $container_name = 'mssqlsrv1'
        $status = docker container ls -a --filter "Name=$($container_name)" --format "{{.Status}}"
        if($status -match 'Up'){
            $docker = docker container ls -a --filter "Name=$($container_name)" --format "{{.Names}}"
            Write-Host "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff')] Container $($docker) $($status)"
        }
        if(-not([String]::IsNullOrEmpty($docker))){
        
            if(-not(Get-InstalledModule -Name dbatools -ea SilentlyContinue)){
                Install-Module -Name dbatools -Force
                $Error.Clear()
            }
            if(-not(Get-Module -Name dbatools)){ Import-Module -Name dbatools }
        
            if([String]::IsNullOrEmpty($sqlcred)){
                $secStringPassword = ConvertTo-SecureString 'yourStrong(!)Password' -AsPlainText -Force
                $sqlcred = New-Object System.Management.Automation.PSCredential ('sa', $secStringPassword)
            }
            $DBname   = 'tinu'
            $Table    = 'inventory'
            $SqlQuery = "SELECT * FROM [$DBname].[dbo].[$Table]"
            $mssqlsrv = Connect-DbaInstance -SqlInstance 'localhost:8433' -SqlCredential $sqlcred
        
            New-PodeWebCard -Name "From MSSQL Table $($Table.ToUpper())" -Content @(
        
                if($mssqlsrv){
                    $properties = @(
                        @{N='Name';E={$_.DeviceName}}
                        @{N='Type';E={$_.DeviceType}}
                        @{N='CPU';E={$_.'Physical cores'}}
                        @{N='Memory';E={ "$($_.MemoryGB) GB"}}
                        @{N='Diskspace';E={ "$($_.DiskspaceGB) GB"}}
                        @{N='Purchased';E={ (Get-Date $_.PurchaseDate -Format 'yyyy-MM-dd') }}
                        @{N='CHF';E={ "{0:N2}" -f $($_.Price) }}
                        'Payment'
                        'Warranty'	
                    )
                    $ResultSqlQuery = Invoke-DbaQuery -SqlInstance $mssqlsrv -Database $DBname -Query $SqlQuery
                    $data = $ResultSqlQuery | Select-Object $properties
                }
                New-PodeWebTextbox -Name '1. Record' -Preformat -Value $($data | Select-Object -First 1)
        
                New-PodeWebTable -ArgumentList @($data, $dummy) -Name 'MSSQL Table' -ScriptBlock {
                    param($data)
                    $data
                }
            )

            New-PodeWebButton -ArgumentList $container_name -Name 'Stop Container' -ScriptBlock {
                param($container_name)
                $stop_container = docker stop $container_name
                Show-PodeWebToast -Message "Container $($stop_container) stopped"
                Write-Host "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff')] Container $($stop_container) stopped"
            }

        }else{
            New-PodeWebCard -Name "Docker Container $($container_name)" -Content @(
                New-PodeWebText -Value "Docker Container is $($status)" -InParagraph
            )
        }
    }

}
