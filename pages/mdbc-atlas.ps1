Add-PodeWebPage -Group 'MongoDB' -Name 'MDBC AtlasDB' -Title 'MongoDB Atlas' -Icon 'database' -ScriptBlock {

    New-PodeWebForm -Name "From MongoDB Collection POWER" -AsCard -ScriptBlock {

        if(-not(Get-InstalledModule -Name Mdbc -ea SilentlyContinue)){
            Install-Module -Name Mdbc -Force
            $Error.Clear()
        }
        if(-not(Get-Module -Name Mdbc)){ Import-Module -Name Mdbc }

        $DatabaseName   = 'tinu'
        $CollectionName = 'power'
        $mongo_client   = Connect-Mdbc "mongodb+srv://$($WebEvent.Data.Token)@cluster0.epl3x.mongodb.net/?retryWrites=true&w=majority"
        $mongo_db       = Get-MdbcDatabase -Name $DatabaseName
        $mongo_col      = Get-MdbcCollection -Database $mongo_db -Name $CollectionName

        if($mongo_col){
            $properties = @(
                'Semester'
                'Period'
                'Kilowatt'
                @{N='CHF';E={"{0:N2}" -f $($_.CHF)}}
            )
            $data = Get-MdbcData -Collection $mongo_col -As PS | Select-Object $properties
            $data | Out-PodeWebTable -Sort
            $data.Where({$_.Kilowatt -ne ''}) | ConvertTo-PodeWebChartData -LabelProperty Semester -DatasetProperty @('Kilowatt','CHF') | Out-PodeWebChart -Type Bar
            #$($data | Select -First 1) | Out-PodeWebTextbox -Multiline -Preformat -AsJson -Size 8
        }
        
    } -Content @(
        New-PodeWebTextbox -Name 'Token' -Placeholder 'Enter user:token' -Type Password
    )


}
