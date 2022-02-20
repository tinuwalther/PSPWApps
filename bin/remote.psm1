function Connect-ToRemoteComputer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [String]$RemoteComputer,

        [Parameter(Mandatory = $true)]
        [String]$Username,

        [Parameter(Mandatory = $true)]
        [SecureString]$Password
    )

    $CachedCreds = New-Object System.Management.Automation.PSCredential ($Username, $Password)
    try{
        return (New-PSSession -ComputerName $RemoteComputer -Credential $CachedCreds -ErrorAction Stop)
    }catch{
        return [PSCustomObject]@{
            State   = 'Error'
            Message = ($_.Exception.Message)
        }
    }
}