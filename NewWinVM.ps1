
function New-MfVhd {
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
    New-VM -Name Win2012 -VHDPath C:\vm\servercore2012r2.vhdx -MemoryStartupBytes 1024mb -Generation 2
    Get-VM win2012 | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName Internal-ICS-NAT
}

# New-MfVhd
# New-MfVm
