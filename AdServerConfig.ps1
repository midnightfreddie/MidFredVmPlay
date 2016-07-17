configuration DsController {
    param (
        $ComputerName = "freddievm1",
        $IPv4Address = "192.168.137.245",
        $IPv6Address = "fd43:4834:bd2d::245"
    )
    Import-DscResource -Module xNetworking
    Node $ComputerName {
        LocalConfigurationManager {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        # # FIXME: New-NetIPAddress will fail if the address already exists
        # Script NetworkSettings {
        #     SetScript = ({
        #         New-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4 -IPAddress "{0}" -PrefixLength 24 -DefaultGateway ("{0}" -replace "\.\d+$", ".1")
        #         New-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv6 -IPAddress "{1}" -PrefixLength 64
        #         Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 192.168.1.3
        #     }) -f $IPv4Address, $IPv6Address
        #     TestScript = { $false }
        #     GetScript = { @{} }
        # }

        xIPAddress IPv4Address {
            IPAddress      = $IPv4Address
            InterfaceAlias = "Ethernet"
            SubnetMask     = 24
            AddressFamily  = "IPV4"
        }

        xIPAddress IPv6Address {
            IPAddress      = $IPv6Address
            InterfaceAlias = "Ethernet"
            SubnetMask     = 64
            AddressFamily  = "IPV6"
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