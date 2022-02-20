# PsNetTools

BeforeDiscovery {
    Import-Module -Name PsNetTools -Force
}

Describe "Test PsNetTools" {

    it "[NEG] Test-PsNetDig should return true" -Tag Dig {
        Mock Test-PsNetDig { return [PSCustomObject]@{ Succeeded = $false } }
        (Test-PsNetDig 'sbb.ch').Succeeded | Should -BeTrue
    }

    it "[POS] Test-PsNetDig should return a PSCustomObject" -Tag Dig {
        Mock Test-PsNetDig { return [PSCustomObject]@{ Succeeded = $false } }
        (Test-PsNetDig 'sbb.ch').Succeeded | Should -BeOfType [PSCustomObject]
    }

    it "[NEG] Test-PsNetPing should return true" -Tag Ping, NotRun {
        Mock Test-PsNetPing { return [PSCustomObject]@{ Succeeded = $false } }
        (Test-PsNetPing -Destination 'sbb.ch').Succeeded | Should -BeTrue
    }

    it "[NEG] Test-PsNetTping should return true" -Tag Ping {
        Mock Test-PsNetTping { return [PSCustomObject]@{ TcpSucceeded = $false } }
        (Test-PsNetTping -Destination 'sbb.ch' -CommonTcpPort HTTPS ).TcpSucceeded | Should -BeTrue
    }

    it "[POS] Test-PsNetUping should return true" -Tag Ping {
        Mock Test-PsNetUping { return [PSCustomObject]@{ UdpSucceeded = $true } }
        (Test-PsNetUping -Destination 'sbb.ch' -UdpPort 53 ).UdpSucceeded | Should -BeTrue
    }

    it "[POS] Test-PsNetWping should return true" -Tag Ping {
        Mock Test-PsNetWping { return [PSCustomObject]@{ HttpSucceeded = $true } }
        (Test-PsNetWping -Destination 'sbb.ch').HttpSucceeded | Should -BeTrue
    }

}

<#
Invoke-Pester -Path .\ -ExcludeTagFilter NotRun -PassThru | ConvertTo-Json -Depth 1 | Set-Content .\data\Test-PsNetTools.json -Encoding utf8 -Force
Invoke-Pester -Path .\ -ExcludeTagFilter NotRun -OutputFile .\data\Test-PsNetTools.JUnitXml -OutputFormat JUnitXml 
Invoke-Pester -Path .\ -ExcludeTagFilter NotRun -OutputFile .\data\Test-PsNetTools.NUnitXml -OutputFormat NUnitXml 
#>