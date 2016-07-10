[CmdletBinding()]
param (
    # [Parameter(Mandatory=$true)]
    # [ValidateNotNullOrEmpty()]
    # [string[]]
    $VmName = "VmScriptedTest",
    $JoinDomain = "ad.xpoo.net",
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
    # ($Xml | Select-Xml -XPath "//unns:AccountData" -Namespace $NameSpace | Select-Object -First 1).Node.InnerText = $AccountData
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
        $ExpandOnNativeBoot = $false,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $UnattendPath
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
        UnattendPath = $UnattendPath
    }
    Convert-WindowsImage @Parameters
}

# Using for reference: http://www.tomsitpro.com/articles/hyper-v-powershell-cmdlets,2-779.html
function New-MfVm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $VmName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $VhdPath
    )
    New-VM -Name $VmName -VHDPath $VhdPath -MemoryStartupBytes 1024mb -Generation 2 |
        Get-VMNetworkAdapter |
        Connect-VMNetworkAdapter -SwitchName Internal-ICS-NAT
}

$VmName | ForEach-Object {
    $VhdPath = "c:\vm\{0}.vhdx" -f $PSItem
    $UnattendFile = New-Item -ItemType File -Path ("{0}\{1}-unattend.xml" -f $PSScriptRoot, $PSItem)
    # djoin.exe requires /savefile , so I'll use this xml file I just created and then immediately overwrite it
    & djoin.exe /provision /domain $JoinDomain /machine $PSItem /savefile "$($UnattendFile.FullName)" /reuse
    # $AccountData = ((Get-Content $UnattendFile) | Out-String) -replace 0x00
    # $AccountData = (Get-Content $UnattendFile -Encoding UTF8) -replace 0x00
    # For some reason there is a null at the end of this string
    $AccountData = (Get-Content $UnattendFile).Trim(0x00)
    # $AccountData[0]
    # $AccountData[1]
    # $AccountData[2]
    # $AccountData
    (New-MfUnattend -AccountData $AccountData -AdminPassword $VmAdminCred.GetNetworkCredential().Password ).OuterXml |
        Set-Content -Path $UnattendFile.FullName
    # break

    New-MfVhd -UnattendPath $UnattendFile.FullName -VhdPath $VhdPath
    New-MfVm -VhdPath $VhdPath -VmName $PSItem
    Start-VM -Name $PSItem
    # Encrypt the file so only the user running the script can read it
    #   although it will be unencrypted when copied into the vhdx.
    $UnattendFile.Encrypt()
    # Remove-Item $UnattendFile
}
