Add-PodeWebPage -Group 'MongoDB' -Name 'MDBC PSModules' -Title 'MongoDB Installed PSModules' -Icon 'database' -ScriptBlock {

    $isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if([String]::IsNullOrEmpty($isrunning)){
        $isrunning = $false
        New-PodeWebCard -Name "Docker Container" -Content @(
            New-PodeWebText -Value "Docker Desktop is not running, please start Docker Desktop" -InParagraph
        )
    }else{
        $isrunning = $true
        $container_name = 'mongodb1'
        $status = docker container ls -a --filter "Name=$($container_name)" --format "{{.Status}}"
        if($status -match 'Up'){
            $docker = docker container ls -a --filter "Name=$($container_name)" --format "{{.Names}}"
            Write-Host "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff')] Container $($docker) $($status)"
        }
        if(-not([String]::IsNullOrEmpty($docker))){
    
            if(-not(Get-InstalledModule -Name Mdbc -ea SilentlyContinue)){
                Install-Module -Name Mdbc -Force
                $Error.Clear()
            }
            if(-not(Get-Module -Name Mdbc)){ Import-Module -Name Mdbc }
    
            $DatabaseName   = 'tinu'
            $CollectionName = 'InstalledPSModules'
            $mongo_client   = Connect-Mdbc mongodb://localhost
            $mongo_db       = Get-MdbcDatabase -Name $DatabaseName
            $mongo_col      = Get-MdbcCollection -Database $mongo_db -Name $CollectionName
    
            New-PodeWebCard -Name "From MongoDB Collection $($CollectionName.ToUpper())" -Content @(
    
                if($mongo_col){
                    $Properties = @(
                        'Name'
                        'Version'
                        'Description'
                        'Author'
                        'CompanyName'
                        'Repository'
                        'PublishedDate'
                        'InstalledDate'
                        'UpdatedDate'
                        'InstalledLocation'
                    )
                    $data = Get-MdbcData -Collection $mongo_col -As PS | Select $Properties
                }
        
                New-PodeWebTable -ArgumentList @($data, $dummy) -Name 'MongoDB Collection' -SimpleSort -SimpleFilter -ScriptBlock {
                    param($data)
                    $data
                }

            )

            New-PodeWebButton -ArgumentList $container_name -Name 'Stop Container' -ScriptBlock {
                param($container_name)
                $stop_container = docker stop $container_name
                Show-PodeWebToast -Message "Container $($stop_container) stopped"
                Write-Host "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff')] Container $($stop_container) stopped"
            }
    
        }else{
            New-PodeWebCard -Name "Docker Container $($container_name)" -Content @(
                New-PodeWebText -Value "Docker Container is $($status)" -InParagraph
            )
        }
    }

}

<#
$Properties = @(
    'Name'
    'Version'
    'Description'
    'Author'
    'CompanyName'
    'Repository'
    @{N='PublishedDate';E={ (Get-Date $_.PublishedDate -f 'yyyy-MM-dd HH:mm:ss') }}
    @{N='InstalledDate';E={ (Get-Date $_.InstalledDate -f 'yyyy-MM-dd HH:mm:ss') }}
    @{N='UpdatedDate';E={ (Get-Date $_.UpdatedDate -f 'yyyy-MM-dd HH:mm:ss') }}
    'InstalledLocation'
)
$InstalledModule = Get-InstalledModule | Select-Object $Properties

Import-Module -Name Mdbc
$DatabaseName   = 'tinu'
$CollectionName = 'InstalledPSModules'
$mongo_client   = Connect-Mdbc mongodb://localhost
$mongo_db       = Get-MdbcDatabase -Name $DatabaseName
$mongo_col      = Get-MdbcCollection -Database $mongo_db -Name $CollectionName

Get-MdbcDatabase -Client $mongo_client
Get-MdbcCollection -Database $mongo_db | Select Collection*,Database

foreach($item in $InstalledModule){
    Add-MdbcData -Collection $mongo_col -InputObject $item
}

Get-MdbcData -Collection $mongo_col -As PS
#>