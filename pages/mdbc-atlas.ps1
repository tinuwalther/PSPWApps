Add-PodeWebPage -Group 'MongoDB' -Name 'MDBC AtlasDB' -Title 'MongoDB Atlas' -Icon 'database' -ScriptBlock {

    New-PodeWebForm -Name "From MongoDB Collection POWER" -AsCard -ScriptBlock {

        if(-not(Get-InstalledModule -Name Mdbc -ea SilentlyContinue)){
            Install-Module -Name Mdbc -Force
            $Error.Clear()
        }
        if(-not(Get-Module -Name Mdbc)){ Import-Module -Name Mdbc }

        $DatabaseName   = 'tinu'
        $CollectionName = 'power'
        $mongo_client   = Connect-Mdbc "mongodb+srv://$($WebEvent.Data.Token1)@cluster0.epl3x.mongodb.net/?retryWrites=true&w=majority"
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
        New-PodeWebTextbox -Id 'Token1' -Name 'Token1' -DisplayName 'Token' -Placeholder 'Enter user:token' -Type Password
    )

    New-PodeWebForm -Name "From MongoDB Collection Inventory" -AsCard -ScriptBlock {

        if(-not(Get-InstalledModule -Name Mdbc -ea SilentlyContinue)){
            Install-Module -Name Mdbc -Force
            $Error.Clear()
        }
        if(-not(Get-Module -Name Mdbc)){ Import-Module -Name Mdbc }

        $DatabaseName   = 'tinu'
        $CollectionName = 'inventory'
        $mongo_client   = Connect-Mdbc "mongodb+srv://$($WebEvent.Data.Token2)@cluster0.epl3x.mongodb.net/?retryWrites=true&w=majority"
        $mongo_db       = Get-MdbcDatabase -Name $DatabaseName
        $mongo_col      = Get-MdbcCollection -Database $mongo_db -Name $CollectionName

        if($mongo_col){
            $properties = @(
                #@{N='ID';E={$($_.ID).ToString()}}
                @{N='Name';E={$_.DeviceName}}
                @{N='Type';E={$_.DeviceType}}
                @{N='CPU';E={$_.'Physical cores'}}
                @{N='Memory';E={ "$($_.MemoryGB) GB"}}
                @{N='Diskspace';E={ "$($_.DiskspaceGB) GB"}}
                @{N='Purchased';E={ (Get-Date $_.PurchaseDate -Format 'yyyy-MM-dd') }}
                @{N='CHF';E={ "{0:N2}" -f $($_.PriceCHF) }}
                @{N='Payment';E={ $_.Payment }}
                @{N='Warranty';E={ $_.Warranty }}
                @{N='AgeYear';E={ [Math]::Round((New-TimeSpan -Start (Get-Date $_.PurchaseDate -Format 'yyyy-MM-dd') -End (Get-Date -Format 'yyyy-MM-dd') | Select-Object -ExpandProperty Days)/365,1) }}
            )
            $data = Get-MdbcData -Collection $mongo_col -As PS | Select-Object $properties
            $data | Out-PodeWebTable -Sort
        }
        
    } -Content @(
        New-PodeWebTextbox -Id 'Token2' -Name 'Token2' -DisplayName 'Token' -Placeholder 'Enter user:token' -Type Password
    )

}
