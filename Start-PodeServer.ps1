Import-Module Pode.Web

Start-PodeServer {

    $EPProperties = @{
        Address  = 'PodeWebApp'
        Port     = 8089
        Protocol = 'https'
        CertificateName = 'PodeWebApp.home'
        CertificateStoreLocation = 'CurrentUser'
    }
    Add-PodeEndpoint @EPProperties
    New-PodeLoggingMethod -Path .\logs -Name "PodeWebServer.log" | Enable-PodeErrorLogging
    
    Use-PodeWebTemplates -Title "PodeWebApp" -Theme Auto
    $Properties = @{
        Name = 'Pode.Web on GitHub'
        Url  = 'https://github.com/Badgerati/Pode.Web'
        Icon = 'help-circle'
    }
    $navgithub  = New-PodeWebNavLink @Properties -NewTab
    Set-PodeWebNavDefault -Items $navgithub

    foreach($item in (Get-ChildItem (Join-Path $PSScriptRoot -ChildPath 'pages')))  {
        . "$($item.FullName)"
    }

    $Path = "microsoft-edge:$($EPProperties.Protocol)://$($EPProperties.Address):$($EPProperties.Port)/"
    Start-Process $Path -WindowStyle maximized
}
