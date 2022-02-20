Add-PodeWebPage -Name 'Pester Reporting' -Title 'Read Pester Tests' -Icon 'file' -ScriptBlock {

    $FilePath = Join-Path (Get-Item $PSScriptRoot).Parent -ChildPath 'data'
    $array = @()
    $array += (Get-ChildItem $FilePath -Filter '*.*UnitXml').FullName

    $Module = Join-PodeWebPath -Path $($PSScriptRoot).Trim('pages') -ChildPath "\bin\Read-FromXML.psm1"
    Import-Module -FullyQualifiedName $Module -Force

    foreach($item in $array){
        $XmlFile = Get-ChildItem $item
        #Write-Host $XmlFile
        New-PodeWebCard -Name "Report from $($XmlFile.Name)" -Content @(

            New-PodeWebGrid -Cells @(

                switch($XmlFile.Extension){
                    '.junitxml' {
                        $PesterJUnitXml = ConvertFrom-PesterJUnitXml -InputFile $XmlFile.FullName
                        #Write-Host $PesterJUnitXml
                    }
                    '.nunitxml' {
                        $PesterJUnitXml = ConvertFrom-PesterNUnitXml -InputFile $XmlFile.FullName
                        #Write-Host $PesterJUnitXml
                    }
                }

                New-PodeWebCell -Content @(
                    New-PodeWebChart -ArgumentList @($PesterJUnitXml) -Name "Doughnut Chart $($item)" -Height '90%' -Type Doughnut -NoRefresh -ScriptBlock {
                        param($PesterJUnitXml)
                        $DiagramData = @(
                            [PSCustomObject]@{
                                Label  = 'Passed' 
                                Value  = $PesterJUnitXml.PassedCount
                            }
                            [PSCustomObject]@{
                                Label  = 'Failed' 
                                Value  = $PesterJUnitXml.FailedCount
                            }
                            [PSCustomObject]@{
                                Label  = 'Skipped' 
                                Value  = $PesterJUnitXml.SkippedCount
                            }
                            [PSCustomObject]@{
                                Label  = 'NotRun'
                                Value  = $PesterJUnitXml.NotRunCount
                            }
                        )
                        $DiagramData | ConvertTo-PodeWebChartData -LabelProperty 'Label' -DatasetProperty 'Value'
                    }
                )
                New-PodeWebCell -Content @(
                    New-PodeWebChart -ArgumentList @($PesterJUnitXml) -Name "Bar Chart $($item)" -Height '90%' -Type Bar -NoRefresh -ScriptBlock {
                        param($PesterJUnitXml)
                        $properties = @(
                            @{N='Test Result';E={'Test Result'}}
                            @{N='Total';E={$_.TotalCount}}
                            @{N='Passed';E={$_.PassedCount}}
                            @{N='Failed';E={$_.FailedCount}}
                            @{N='Skipped';E={$_.SkippedCount}}
                            @{N='NotRun';E={$_.NotRunCount}}
                        )
                        $DiagramData = $PesterJUnitXml | Select-Object $properties
                        $DiagramData | ConvertTo-PodeWebChartData -LabelProperty 'Test Result' -DatasetProperty @('Total','Passed','Failed','Skipped','NotRun')
                    }
                )
                New-PodeWebCell -Content @(
                    New-PodeWebChart -ArgumentList @($PesterJUnitXml) -Name "Doughnut Pie $($item)" -Height '90%' -Type Pie -NoRefresh -ScriptBlock {
                        param($PesterJUnitXml)
                        $DiagramData = @(
                            [PSCustomObject]@{
                                Label  = 'Passed' 
                                Value  = $PesterJUnitXml.PassedCount
                            }
                            [PSCustomObject]@{
                                Label  = 'Failed' 
                                Value  = $PesterJUnitXml.FailedCount
                            }
                            [PSCustomObject]@{
                                Label  = 'Skipped' 
                                Value  = $PesterJUnitXml.SkippedCount
                            }
                            [PSCustomObject]@{
                                Label  = 'NotRun'
                                Value  = $PesterJUnitXml.NotRunCount
                            }
                        )
                        $DiagramData | ConvertTo-PodeWebChartData -LabelProperty 'Label' -DatasetProperty 'Value'
                    }
                )
            )

            New-PodeWebTable -ArgumentList @($PesterJUnitXml) -Name "Collection $($item)" -SimpleSort -SimpleFilter -ScriptBlock {
                param($PesterJUnitXml)
                $PesterJUnitXml.Tests
            }

        )
    }

}
