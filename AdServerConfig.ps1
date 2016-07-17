configuration DsController {
    param (
        $ComputerName = "freddievm1",
        $IPv4Address = "192.168.137.245",
        $IPv6Address = "fd43:4834:bd2d::245"
    )
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
                @{ Result = (Get-NetIPAddress -InterfaceAlias Ethernet | Select-Object -ExpandProperty IPAddress) -join ", " }
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
                @{ Result = (Get-NetIPAddress -InterfaceAlias Ethernet | Select-Object -ExpandProperty IPAddress) -join ", " }
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