function Initialize-MongoDB {
    <#
        Return MongoDBCollection-Object
    #>
    [CmdletBinding()]
    param ()
    
    if(-not(Get-InstalledModule -Name Mdbc -ea SilentlyContinue)){
        Install-Module -Name Mdbc -Force
        $Error.Clear()
    }

    if(-not(Get-Module -Name Mdbc)){ Import-Module -Name Mdbc }

    $MdbcProperties = @{
        DatabaseName     = 'tinu'
        CollectionName   = 'inventory'
        ConnectionString = 'mongodb://localhost'
    }
    return Get-MongoDBCollection @MdbcProperties                    

}

function Get-MongoDBCollection {
    param (
        [Parameter(Mandatory=$true)]
        [String]$DatabaseName,

        [Parameter(Mandatory=$true)]
        [String]$CollectionName,

        [Parameter(Mandatory=$true)]
        [String]$ConnectionString
    )

    Connect-Mdbc -ConnectionString $ConnectionString
    $mongo_db  = Get-MdbcDatabase -Name $DatabaseName
    return (Get-MdbcCollection -Database $mongo_db -Name $CollectionName)
}

function Get-MongoDBData {
    <#
        Return all documents
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Object]$Collection
    )
    $properties = @(
        @{N='ID';E={$($_.ID).ToString()}}
        @{N='Name';E={$_.DeviceName}}
        @{N='Type';E={$_.DeviceType}}
        @{N='CPU';E={$_.'Physical cores'}}
        @{N='Memory';E={ "$($_.MemoryGB) GB"}}
        @{N='Diskspace';E={ "$($_.DiskspaceGB) GB"}}
        @{N='Purchased';E={ (Get-Date $_.PurchaseDate -Format 'yyyy-MM-dd') }}
        @{N='CHF';E={ "{0:N2}" -f $($_.Price) }}
        @{N='Payment';E={ $_.Payment }}
        @{N='Warranty';E={ $_.Warranty }}
    )

    return (Get-MdbcData -Collection $Collection -As PS | Select-Object $properties)
}

function Get-MongoDBDocument {
    <#
        Return one document by filter
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Object]$Collection,

        [Parameter(Mandatory=$true)]
        [Object]$Filter
    )
    $properties = @(
        @{N='ID';E={$($_.ID).ToString()}}
        @{N='Name';E={$_.DeviceName}}
        @{N='Type';E={$_.DeviceType}}
        @{N='CPU';E={$_.'Physical cores'}}
        @{N='Memory';E={ "$($_.MemoryGB) GB"}}
        @{N='Diskspace';E={ "$($_.DiskspaceGB) GB"}}
        @{N='Purchased';E={ (Get-Date $_.PurchaseDate -Format 'yyyy-MM-dd') }}
        @{N='CHF';E={ "{0:N2}" -f $($_.Price) }}
        @{N='Payment';E={ $_.Payment }}
        @{N='Warranty';E={ $_.Warranty }}
    )

    return (Get-MdbcData -Collection $Collection -Filter $Filter | Select-Object $properties)
}

function Add-MongoDBDocument {
    <#
        Return the new added document
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Object]$Collection,

        [Parameter(Mandatory=$true)]
        [Object]$Document
    )
    $null = Add-MdbcData -Collection $Collection -InputObject $Document
    return (Get-MongoDBDocument -Collection $Collection -Filter @{ID = $Document.ID})
}

function Update-MongoDBDocument {
    <#
        Update the document
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Object]$Filter,
        
        [Parameter(Mandatory=$true)]
        [Object]$Collection,

        [Parameter(Mandatory=$true)]
        [Object]$Document
    )
    $null = Update-MdbcData -Filter $Filter -Update @{'$set' = $Document} -Collection $Collection #-Result
    return (Get-MongoDBDocument -Collection $Collection -Filter $Filter)
}


function Remove-MongoDBDocument {
    <#
        Return nothing
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Object]$Collection,

        [Parameter(Mandatory=$true)]
        [Object]$Filter
    )
    $ret = (Get-MongoDBDocument -Collection $Collection -Filter $Filter)
    $null = Remove-MdbcData -Collection $Collection -Filter $Filter
    return $ret
}

<#
    Import-Module .\functions\docker.psm1 -Force
    Import-Module .\functions\mongodb.psm1 -Force

    $IsRunning = Test-IsDockerRunning

    $status = Test-IsContainerRunning -ContainerName $container_name

    Initialize-MongoDB
    $MdbcProperties = @{
        DatabaseName     = 'tinu'
        CollectionName   = 'inventory'
        ConnectionString = 'mongodb://localhost'
    }
    $mongo_col = Get-MongoDBCollection @MdbcProperties                    

#>