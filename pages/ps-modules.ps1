Add-PodeWebPage -Name 'PowerShell Modules' -Title 'PowerShell Modules' -Icon 'cog' -ScriptBlock {
    
    # set the home page controls
    New-PodeWebAccordion -Bellows @(

        New-PodeWebBellow -Name 'Find Module' -Content @(
            New-PodeWebForm -Name 'Search for Module' -ScriptBlock {
                $Properties = @(
                    'Name'
                    'Version'
                    'Description'
                    'Author'
                    'CompanyName'
                    'Copyright'
                    @{N='PublishedDate';E={ (Get-Date $_.PublishedDate -f 'yyyy-MM-dd HH:mm:ss') }}
                )
                Find-Module -Name $WebEvent.Data.Name | Select-Object $Properties | Out-PodeWebTable
            } -Content @(
                New-PodeWebTextbox -Name 'Name' -Placeholder 'Enter a Module name'
            )
        )

        New-PodeWebBellow -Name 'Installed Modules' -Content @(
            New-PodeWebTable -Name 'Installed Modules' -SimpleSort -SimpleFilter -ScriptBlock {
                $Properties = @(
                    'Name'
                    'Version'
                    'Description'
                    'Author'
                    'CompanyName'
                    'Repository'
                    'PublishedDate'
                    @{N='PublishedDate';E={ (Get-Date $_.PublishedDate -f 'yyyy-MM-dd HH:mm:ss') }}
                    @{N='InstalledDate';E={ (Get-Date $_.InstalledDate -f 'yyyy-MM-dd HH:mm:ss') }}
                    @{N='UpdatedDate';E={ (Get-Date $_.UpdatedDate -f 'yyyy-MM-dd HH:mm:ss') }}
                    'InstalledLocation'
                )
                Get-InstalledModule | Select-Object $Properties
            }
        )

        New-PodeWebBellow -Name 'Update Modules' -Content @(

            New-PodeWebForm -Name 'Modules' -ScriptBlock {
                $Modules = $WebEvent.Data['Modules']
                $Properties = @(
                    'Name'
                    'Version'
                    @{N='InstalledDate';E={ (Get-Date $_.InstalledDate -f 'yyyy-MM-dd HH:mm:ss') }}
                    @{N='UpdatedDate';E={ (Get-Date $_.UpdatedDate -f 'yyyy-MM-dd HH:mm:ss') }}
                )
                $ret = foreach($item in ($Modules -split ',')){
                    $null = Remove-Module -Name $item -Force
                    Update-Module -Name $item -Force -PassThru -Confirm:$false -Verbose
                }
                $ret | Select-Object $Properties | Out-PodeWebTable -Sort
                
            } -Content @(
                $AvailableModule = Get-InstalledModule | Select-Object -ExpandProperty Name #Get-Module -ListAvailable | Select-Object -ExpandProperty Name -Unique
                New-PodeWebCheckbox -Name 'Modules' -Options $AvailableModule -AsSwitch
            )
    
        )

        New-PodeWebBellow -Name 'Available Modules' -Content @(
            New-PodeWebTable -Name 'Available Modules' -SimpleSort -SimpleFilter -ScriptBlock {
                $Properties = @(
                    'Name'
                    @{N='Version';E={ ($_.Version).ToString() }}
                    'ModuleBase'
                )
                Get-Module -ListAvailable | Select-Object $Properties
            }
        )

    )    

}