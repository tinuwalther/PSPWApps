Add-PodeWebPage -Group 'MongoDB' -Name 'MDBC InventoryDB' -Title 'MongoDB CRUD operations' -Icon 'database' -ScriptBlock {
    
    Import-Module .\bin\docker.psm1  -Force

    $IsRunning = Test-IsDockerRunning
    if($IsRunning){
        $container_name = 'mongodb1'
        $status = Test-IsContainerRunning -ContainerName $container_name
        if($status -match 'Up'){
            #Show-PodeWebToast -Message "Container $($container_name) $($status)" -> this ends in a empty page!
            New-PodeWebAccordion -Bellows @(

                New-PodeWebBellow -Name 'Create - Add new document' -Content @(
                    New-PodeWebForm -Id 1 -Name 'Add new document' -ScriptBlock {
                        Import-Module .\bin\mongodb.psm1 -Force
                        $mongo_col = Initialize-MongoDB
                        
                        $document1 = @{
                            ID               = $(New-Guid).ToString()
                            RunTime	         = Get-Date -Format s
                            DeviceName	     = $WebEvent.Data.Name
                            DeviceType	     = $WebEvent.Data.Type
                            'Physical cores' = [Int]$WebEvent.Data.CPU
                            MemoryGB         = [Int]$WebEvent.Data.Memory
                            DiskspaceGB      = [Int]$WebEvent.Data.Diskspace
                            PurchaseDate     = Get-Date $WebEvent.Data.Purchased -Format s
                            Price            = [Double]$WebEvent.Data.CHF
                            Payment	         = $WebEvent.Data.Payment
                            Warranty         = $WebEvent.Data.Warranty
                            Link             = $WebEvent.Data.Link
                        }
                        $NewDocument = Add-MongoDBDocument -Collection $mongo_col -Document $document1
                        $NewDocument | Out-PodeWebTable
                        Show-PodeWebToast -Message "Added $($NewDocument.ID)"
                        Move-PodeWebAccordion -Name 'Read - List all documents'

                    } -Content @(
                        New-PodeWebTextbox -Name 'Name'      -Value 'ThinkPad'
                        New-PodeWebTextbox -Name 'Type'      -Value 'Notebook'
                        New-PodeWebTextbox -Name 'CPU'       -Value '4'
                        New-PodeWebTextbox -Name 'Memory'	 -Value '8'
                        New-PodeWebTextbox -Name 'Diskspace' -Value '512'
                        New-PodeWebTextbox -Name 'Purchased' -Value '2021-12-21'
                        New-PodeWebTextbox -Name 'CHF'       -Value '1999'
                        New-PodeWebSelect  -Name 'Payment'   -Options @('Cash','Maestrocard','Mastercard','Visacard','Invoice')
                        New-PodeWebTextbox -Name 'Warranty'  -Value '2+1'
                        New-PodeWebTextbox -Name 'Link'      -Value 'https://tinuwalther.github.io'
                    )
                )

                New-PodeWebBellow -Name "Read - List all documents" -Content @(
                    New-PodeWebTable -Id 2 -Name 'List all documents' -SimpleSort -SimpleFilter -ScriptBlock {
                        Import-Module .\bin\mongodb.psm1 -Force
                        $mongo_col = Initialize-MongoDB
                        Get-MongoDBData -Collection $mongo_col
                    }
                )

                New-PodeWebBellow -Name 'Update - Update one document' -Content @(
                    New-PodeWebForm -Id 3 -Name 'Update one document' -ScriptBlock {
                        Import-Module .\bin\mongodb.psm1 -Force
                        $mongo_col = Initialize-MongoDB

                        $filter_json3 = @{ID = $WebEvent.Data.ID}
                        $document3 = @{
                            RunTime	         = Get-Date -Format s # --> Element name 'RunTime' is not valid'
                            DeviceName	     = [String]$WebEvent.Data.Name
                            DeviceType	     = [String]$WebEvent.Data.Type
                            'Physical cores' = [Int]$WebEvent.Data.CPU
                            MemoryGB         = [Int]$WebEvent.Data.Memory
                            DiskspaceGB      = [Int]$WebEvent.Data.Diskspace
                            PurchaseDate     = Get-Date $WebEvent.Data.Purchased -Format s
                            Price            = [Double]$WebEvent.Data.CHF
                            Payment	         = [String]$WebEvent.Data.Payment
                            Warranty         = [String]$WebEvent.Data.Warranty
                            Link             = [String]$WebEvent.Data.Link
                        }
                        $UpdateDocument = Update-MongoDBDocument -Filter $filter_json3 -Collection $mongo_col -Document $document3
                        $UpdateDocument | Out-PodeWebTable
                        Show-PodeWebToast -Message "Updated $($UpdateDocument.ID)"
                        Move-PodeWebAccordion -Name 'Read - List all documents'

                    } -Content @(
                        New-PodeWebTextbox -Name 'ID'        -Value 'Enter the ID of the document to update'
                        New-PodeWebTextbox -Name 'Name'      -Value 'ThinkPad'
                        New-PodeWebTextbox -Name 'Type'      -Value 'Notebook'
                        New-PodeWebTextbox -Name 'CPU'       -Value '4'
                        New-PodeWebTextbox -Name 'Memory'	 -Value '8'
                        New-PodeWebTextbox -Name 'Diskspace' -Value '512'
                        New-PodeWebTextbox -Name 'Purchased' -Value '2021-12-21'
                        New-PodeWebTextbox -Name 'CHF'       -Value '1999'
                        New-PodeWebSelect  -Name 'Payment'   -Options @('Cash','Maestrocard','Mastercard','Visacard','Invoice')
                        New-PodeWebTextbox -Name 'Warranty'  -Value '2+1'
                        New-PodeWebTextbox -Name 'Link'      -Value 'https://tinuwalther.github.io'
                    )
                )

                New-PodeWebBellow -Name 'Delete - Remove one document' -Content @(
                    New-PodeWebForm -Id 4 -Name "Remove document" -ScriptBlock {
                        Import-Module .\bin\mongodb.psm1 -Force
                        $mongo_col = Initialize-MongoDB

                        $filter_json4 = @{ID = $WebEvent.Data.ID} 
                        $data = Get-MongoDBDocument -Collection $mongo_col -Filter $filter_json4
                        Show-PodeWebToast -Message "Removed $($data.ID)"
                        Remove-MongoDBDocument -Collection $mongo_col -Filter $filter_json4 | Out-PodeWebTable
                        Move-PodeWebAccordion -Name 'Read - List all documents'
                    } -Content @(
                        New-PodeWebTextbox -Name 'ID'
                    )
                )
            )

        }else{
            New-PodeWebCard -Name "Docker Container $($container_name)" -Content @(
                New-PodeWebText -Value "Docker Container is $($status)" -InParagraph
            )
        }
    }else{
        New-PodeWebCard -Name "Docker Container" -Content @(
            New-PodeWebText -Value "Docker Desktop is not running, please start Docker Desktop" -InParagraph
        )
    }

}
