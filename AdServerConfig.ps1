configuration DsController {
    param (
        $ComputerName = "freddievm1",
        $IPLastOctet = "245",
        $IPv4Prefix = "192.168.137.",
        $IPv6Prefix = "fd43:4834:bd2d::"
    )
    $IPv4Address = "$IPv4Prefix$IPLastOctet"
    $IPv6Address = "$IPv6Prefix$IPLastOctet"
    Node $ComputerName {
        LocalConfigurationManager {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        Script IPv4Address {
            SetScript = ({
                New-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4 -IPAddress "{0}" -PrefixLength 24 -DefaultGateway ("{0}" -replace "\.\d+$", ".1")
                Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 192.168.1.3
            }) -f $IPv4Address
            TestScript = ({
                "{0}" -in (Get-NetIPAddress -InterfaceAlias Ethernet | Select-Object -ExpandProperty IPAddress)
            }) -f $IPv4Address
            GetScript = {
                @{ Result = (Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress) -join ", " }
            }
        }

        Script IPv6Address {
            SetScript = ({
                New-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv6 -IPAddress "{0}" -PrefixLength 64
            }) -f $IPv6Address
            TestScript = ({
                "{0}" -in (Get-NetIPAddress -InterfaceAlias Ethernet | Select-Object -ExpandProperty IPAddress)
            }) -f $IPv6Address
            GetScript = {
                @{ Result = (Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv6 | Select-Object -ExpandProperty IPAddress) -join ", " }
            }
        }

        Script AdvertiseRoute {
            SetScript = ({
                Get-NetRoute -InterfaceAlias Ethernet -AddressFamily IPv6 |
                    Where-Object {{ $PSItem.DestinationPrefix -match "{0}" }} |
                    Set-NetRoute -Publish Yes
            }) -f $IPv6Prefix
            TestScript = ({
                (Get-NetRoute -InterfaceAlias Ethernet -AddressFamily IPv6 | Where-Object {{ $PSItem.DestinationPrefix -eq "{0}/64" }}).Publish -eq "Yes"
            }) -f $IPv6Prefix
            GetScript = {
                @{ Result = Get-NetRoute -InterfaceAlias Ethernet -AddressFamily IPv6 | Select-Object Publish, DestinationPrefix | Format-List }
            }
        }
        Script EnableAdvertising {
            SetScript = { Get-NetIPInterface -InterfaceAlias Ethernet -AddressFamily IPv6 | Set-NetIPInterface -Advertising Enabled }
            TestScript = { (Get-NetIPInterface -InterfaceAlias Ethernet -AddressFamily IPv6).Advertising -eq "Enabled" }
            GetScript = {
                @{ Result = Get-NetIPInterface -InterfaceAlias Ethernet -AddressFamily IPv6 | Select-Object Advertising, AddressFamily, InterfaceAlias | Format-List }
            }
        }

        Script TimeZone {
            SetScript = { & tzutil.exe /s "Central Standard Time" }
            TestScript = { "Central Standard Time" -eq (& tzutil.exe /g) }
            GetScript = {
                @{ Result = & tzutil.exe /g }
            }
        }        

        # WindowsFeature ADDSInstall {
        #     Ensure = "Present"
        #     Name = "AD-Domain-Services"
        # }
        WindowsFeature DHCP {
            Ensure = "Present"
            Name = "DHCP"
        }
        WindowsFeature DNS {
            Ensure = "Present"
            Name = "DNS"
        }
    }
}