Add-PodeWebPage -Name 'PowerShell Remoting' -Title 'WinRM is SSH for Windows!' -Icon 'cog' -ScriptBlock {

    <#
    RunAs Admin for changes on TrustedHosts
    $CurrentList = (Get-Item WSMan:\localhost\Client\TrustedHosts).value
    Set-Item WSMan:\localhost\Client\TrustedHosts -Concatenate -Value *.home
    Enter-PSSession -ComputerName '2bfd5187.home' -Credential (Get-Credential -UserName '2bfd5187\tinu')
    $TcpTest = Test-PsNetTping -Destination $Remotehost -TcpPort 5985
    #>

    $Days = 1
    New-PodeWebCard -Name 'Trusted Hosts' -Content @(
        New-PodeWebTable -Name 'Hostlist' -SimpleSort -Compact -NoExport -NoRefresh -ScriptBlock {
            $WsMan = (Get-Item WSMan:\localhost\Client\TrustedHosts)
            $Properties = @(
                'Name'
                'SourceOfValue'
                'Value'
            )
            $WsMan | Select-Object $Properties
        }
    )

    New-PodeWebCard -Name "System Events of the last $Days days" -Content @(
        New-PodeWebForm -ArgumentList $Days -Name "Remote Computer" -ScriptBlock {
            param($Days)
            $Module = Join-PodeWebPath -Path $($PSScriptRoot).Trim('pages') -ChildPath "\functions\eventlog.psm1"
            Import-Module -FullyQualifiedName $Module -Force

            if([String]::IsNullOrEmpty($WebEvent.Data.Computer)){
                $SystemLogs = Get-SystemLogs -Days $Days -EventID @(13,26,41,42,107,109,161,1001,1074,1076,2004,6005,6006,6008,7022,7031,7043)   
                Out-PodeWebTable -Data $SystemLogs -Sort
            }else{
                $Module = Join-PodeWebPath -Path $($PSScriptRoot).Trim('pages') -ChildPath "\functions\remote.psm1"
                Import-Module -FullyQualifiedName $Module -Force
                $Properties = @{
                    RemoteComputer = $($WebEvent.Data.Computer)
                    Username       = $($WebEvent.Data.User)
                    Password       = ConvertTo-SecureString $($WebEvent.Data.Password) -AsPlainText -Force
                }
                $WSMan = Connect-ToRemoteComputer @Properties
                #$WSMan | Select-Object Id, Name,Transport, ComputerName, State, Availability | Out-PodeWebTextbox -Multiline -Preformat -AsJson
                if($WSMan.State -eq 'Opened'){
                    #Show-PodeWebToast -Message "Session to $($WebEvent.Data.Computer) is $($WSMan.Availability)"                    
                    $SystemLogs = Get-SystemLogs -RemoteSession $WSMan -Days 1 -EventID @(13,41,42,107,109,161,1001,1074,1076,2004,6005,6006,6008,7031,7043)   
                    Out-PodeWebTable -Data $SystemLogs -Sort
                    Remove-PSSession $WSMan
                    #Show-PodeWebToast -Message "Session to $($WebEvent.Data.Computer) is $($WSMan.State)"
                }else{
                    "Could not establish a remote session to $($Properties.RemoteComputer) with user $($Properties.Username)" | Out-PodeWebTextbox
                }
            }
        } -Content @(
            New-PodeWebTextbox -Name 'Computer' -Placeholder 'Enter the DNSname or IPAddress of the remote Computer' -Type Text
            New-PodeWebTextbox -Name 'User'     -Placeholder 'Enter the Username of the remote Computer' -Type Text #NoForm
            New-PodeWebTextbox -Name 'Password' -Placeholder 'Enter the Password of the Username' -Type Password #-NoForm
        )
    )

    <#
    New-PodeWebCard -Name "Application Crashes of the last $Days days" -Content @(
        New-PodeWebTable -ArgumentList $Days -Name 'ApplicationReport' -SimpleSort -SimpleFilter -ScriptBlock {
            param($Days)
            $Module = Join-PodeWebPath -Path $($PSScriptRoot).Trim('pages') -ChildPath "\functions\eventlog.psm1"
            Import-Module -FullyQualifiedName $Module -Force
            Get-ApplicationLogs -Days $Days -EventID @(1000,1002,1026)
        }
    )
    #>
}
