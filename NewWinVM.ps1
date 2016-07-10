[CmdletBinding()]
param (
    $VmAdminCred = (Get-Credential -UserName "Administrator" -Message "Enter password for new VM's local admin account. The username isn't used here.")
)

# Load basic unattend.xml template and fill in some values
# $AccountData is the output of djoin for offline domain join
function New-MfUnattend {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $AccountData,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $AdminPassword,
        $RegisteredOwner = "midnightFreddie",
        $RegisteredOrganization = "midnightFreddie.com"
    )
    $NameSpace = @{
        unns = "urn:schemas-microsoft-com:unattend"
        wcm = "http://schemas.microsoft.com/WMIConfig/2002/State"
    }
    $Xml = [xml](Get-Content $PSScriptRoot\unattend.xml)
    # $Xml.unattend.SelectSingleNode("AccountData")
    ($Xml | Select-Xml -XPath "//unns:AccountData" -Namespace $NameSpace | Select-Object -First 1).Node.InnerXml = $AccountData
    ($Xml | Select-Xml -XPath "//unns:AdministratorPassword/unns:Value" -Namespace $NameSpace | Select-Object -First 1).Node.InnerXml = $AdminPassword
    ($Xml | Select-Xml -XPath "//unns:RegisteredOwner" -Namespace $NameSpace | Select-Object -First 1).Node.InnerXml = $RegisteredOwner
    ($Xml | Select-Xml -XPath "//unns:RegisteredOrganization" -Namespace $NameSpace | Select-Object -First 1).Node.InnerXml = $RegisteredOrganization
    $Xml
}

function New-MfVhd {
    [CmdletBinding()]
    param (
        $SourcePath = "D:\sources\install.wim",
        $Edition = "SERVERSTANDARDCORE",
        $VhdPath = "C:\vm\servercore2012r2.vhdx",
        $SizeBytes = 127GB,
        $DiskLayout = "UEFI",
        $ExpandOnNativeBoot = $false
    )
    # From https://github.com/Microsoft/Virtualization-Documentation
    # Specifically https://github.com/Microsoft/Virtualization-Documentation/tree/master/hyperv-tools/Convert-WindowsImage
    Import-Module Convert-WindowsImage
    # Was using my own fork to fix the -DiskLayout BIOS problem, but I submitted a pull request to fix it and also am now using UEFI, anyway
    # Import-Module C:\Users\Jim.AD\Documents\git\Virtualization-Documentation\hyperv-tools\Convert-WindowsImage -Force

    $Parameters = @{
        SourcePath = $SourcePath
        Edition = $Edition
        VhdPath = $VhdPath
        SizeBytes = $SizeBytes
        DiskLayout = $DiskLayout
        ExpandOnNativeBoot = $ExpandOnNativeBoot
    }
    Convert-WindowsImage @Parameters
}

# Using for reference: http://www.tomsitpro.com/articles/hyper-v-powershell-cmdlets,2-779.html
function New-MfVm {
    # [CmdletBinding()]
    New-VM -Name Win2012 -VHDPath C:\vm\servercore2012r2.vhdx -MemoryStartupBytes 1024mb -Generation 2
    Get-VM win2012 | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName Internal-ICS-NAT
}

# New-MfVhd
# New-MfVm
(New-MfUnattend -AccountData "__accountdata__" -AdminPassword $VmAdminCred.GetNetworkCredential().Password ).OuterXml
# New-MfUnattend
