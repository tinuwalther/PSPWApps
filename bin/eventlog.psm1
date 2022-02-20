function Get-SystemLogs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Object]$RemoteSession,

        [Parameter(Mandatory=$false)]
        [int[]]$EventID = @(13,41,42,107,109,161,1001,1074,1076,2004,6005,6006,6008,7031,7043),

        [Parameter(Mandatory=$false)]
        [Int]$Days = 7
    )
    
    $ScriptBlockContent = {
        param(
            [Parameter(Mandatory=$true)] [Int]$Days,
            [Parameter(Mandatory=$true)] [Int[]]$EventID
        )
        $WinEventProp = @{
            LogName   = 'System'
            Id        = $EventID
            StartTime = (Get-Date).AddDays(-$Days)
            EndTime   = (Get-Date)
        }    
        Get-WinEvent -FilterHashtable $WinEventProp | Sort-Object TimeCreated -Descending
    }

    if($RemoteSession){
        $WinEvent = Invoke-Command -Session $RemoteSession -ScriptBlock $ScriptBlockContent -ArgumentList $Days,$EventID
        $Computer = $RemoteSession.ComputerName
    }else{
        $WinEvent = Invoke-Command -ScriptBlock $ScriptBlockContent -ArgumentList $Days,$EventID
        $Computer = $env:COMPUTERNAME
    }

    $ret = foreach($item in $WinEvent){
        switch($item.ID){
            13   {$detail = 'System shutdown';$Type = 'Shutdown'}
            41   {$detail = 'System stopped';$Type = 'Crash'}
            42   {$detail = 'System going to sleep';$Type = 'Sleep'}
            107  {$detail = 'Wake up from sleep';$Type = 'Sleep'}
            109  {$detail = 'System shutdown';$Type = 'Shutdown'}
            161  {$detail = 'Memory dump';$Type = 'Crash'}
            1001 {$detail = 'Memory dump';$Type = 'Crash'}
            1074 {
                $null = $item.Message -match '\w+\.exe'
                $BehalfOf = $Matches[0]
                if($item.Message -match 'power off'){
                    $detail = "Shutdown by User on behalf of $($BehalfOf)"
                    $Type = 'Shutdown'
                }
                if($item.Message -match 'restart'){
                    $Type = 'Restart'
                    if($item.Message -match 'NT AUTHORITY\\SYSTEM'){
                        $detail = "Restart by SYSTEM on behalf of $($BehalfOf)"
                    }else{
                        $detail = "Restart by User on behalf of $($BehalfOf)"
                    }
                }
            }
            1076 {
                $detail = 'Unexpected shutdown';$Type = 'Crash'
            }
            2004 {
                $Type   = 'Memory'
                $null   = $item.Message -match '(?<=The following programs consumed the most virtual memory\:\s)(.*)(?=\s\(\d{0,4}\)\sconsumed)'
                $detail = $($Matches[0]) -split '\s'
                $detail = "Low Memory Condition $($detail[0])"

            }
            6005 {$detail = 'System startup';$Type = 'Startup'}
            6006 {$detail = 'System shutdown';$Type = 'Shutdown'}
            6008 {
                $Type = 'Shutdown'
                $detail = 'Unexpected shutdown'
                $null = $item.Message -match '\d{2}\:\d{2}\:\d{2}'
                $time = $Matches[0]
                $null = $item.Message -match '(?<=on\s)(.*)(?= was)'
                $date = $Matches[0] -replace '‎'
                $detail = "$($detail) at $(Get-Date "$($date) $($time)" -f 'yyyy-MM-dd HH:mm:ss')"
            }
            7031 {$detail = 'Service terminated unexpectedly';$Type = 'Crash'}
            default {$Type = $item.id;$detail = 'n/a'}
        }
        [PSCustomObject]@{
            Computer    = $Computer
            TimeCreated = (Get-Date $item.TimeCreated -f 'yyyy-MM-dd HH:mm:ss')
            Type        = $Type
            EventID     = $item.ID
            Detail      = $detail
            Message     = $item.Message
        }
    }
    return $ret
}

function Get-ApplicationLogs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Object]$RemoteSession,

        [Parameter(Mandatory=$false)]
        [int[]]$EventID = @(1000,1026),

        [Parameter(Mandatory=$false)]
        [Int]$Days = 7
    )
    
    $ScriptBlockContent = {
        param(
            [Parameter(Mandatory=$true)] [Int]$Days,
            [Parameter(Mandatory=$true)] [Int[]]$EventID
        )
        $WinEventProp = @{
            LogName   = 'Application'
            Id        = $EventID
            StartTime = (Get-Date).AddDays(-$Days)
            EndTime   = (Get-Date)
        }    
        Get-WinEvent -FilterHashtable $WinEventProp | Sort-Object TimeCreated -Descending
    }

    if($RemoteSession){
        $WinEvent = Invoke-Command -Session $RemoteSession -ScriptBlock $ScriptBlockContent -ArgumentList $Days,$EventID
    }else{
        $WinEvent = Invoke-Command -ScriptBlock $ScriptBlockContent -ArgumentList $Days,$EventID
    }

    $ret = foreach($item in $WinEvent){
        switch($item.ID){
            default {
                $Type = $item.id
                $null = $item.Message -match '\w+\.exe'
                $detail = $Matches[0]
            }
        }
        [PSCustomObject]@{
            TimeCreated = (Get-Date $item.TimeCreated -f 'yyyy-MM-dd HH:mm:ss')
            Type        = $Type
            Source      = $item.ProviderName
            Detail      = $detail
            Message     = $item.Message
        }
    }
    return $ret
}
