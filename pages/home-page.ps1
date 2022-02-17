Set-PodeWebHomePage -Layouts @(

    New-PodeWebHero -Title 'Welcome!' -Message 'This is the Pode.Web home page' -Content @(
        
        New-PodeWebText -Value 'Start pode server: Start-PodeServer.ps1' -InParagraph
        New-PodeWebText -Value 'Restart pode server: Ctrl. + R' -InParagraph
        New-PodeWebText -Value 'Stop pode server: Ctrl. + C' -InParagraph
        New-PodeWebText -Value 'All Pages are locatad in ./PodeWeb/pages/' -InParagraph
        
    )

)
