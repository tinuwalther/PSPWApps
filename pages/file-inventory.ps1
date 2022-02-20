Add-PodeWebPage -Name 'File Inventory' -Title 'Inventory from File' -Icon 'file' -ScriptBlock {
        
    New-PodeWebCard -Name 'Load Inventory from File' -Content @(
            
        $array = @()
        $array += 'Choose...'
        $FilePath = Join-Path (Get-Item $PSScriptRoot).Parent -ChildPath 'data'
        $array += (Get-ChildItem $FilePath).Name
        
        New-PodeWebSelect -Name 'File' -Options $array |
        Register-PodeWebEvent -ArgumentList $FilePath -Type Change -ScriptBlock {
            param($FilePath)
            $properties = @(
                @{N='Name';E={$_.DeviceName}}
                @{N='Type';E={$_.DeviceType}}
                @{N='CPU';E={$_.'Physical cores'}}
                @{N='Memory';E={ "$($_.MemoryGB) GB"}}
                @{N='Diskspace';E={ "$($_.DiskspaceGB) GB"}}
                @{N='Purchased';E={ (Get-Date $_.PurchaseDate -Format 'yyyy-MM-dd') }}
                @{N='CHF';E={ "{0:N2}" -f $($_.PriceCHF) }}
                'Payment'
                'Warranty'	
            )
            try{
                $file = Join-Path $FilePath -ChildPath $($WebEvent.Data.File) -ErrorAction Stop
                #Show-PodeWebToast -Message "$($file)"
                switch -Regex ($WebEvent.Data.File){
                    '\.json' {$data = Get-Content -Path $file | ConvertFrom-Json | Select-Object $properties}
                    '\.csv'  {$data = Import-Csv -Path $file | Select-Object $properties}
                }
                Out-PodeWebTable -Sort -Data $data
                $data | Select-Object -First 1 | Out-PodeWebTextbox -Multiline -Preformat -AsJson    
            }catch{
                New-PodeWebAlert -Type Warning -Value $($_.Exception.Message)
            }

        }        

    )
}
