param (
    # $WimFile = "C:\temp\deleteme\sources\install.wim"
    $WimFile = "D:\sources\install.wim"
)

function New-MfVhd {
    param (
        [Param(Mandatory=$true)]
        $WimFile
    )
    # From https://github.com/Microsoft/Virtualization-Documentation
    # Specifically https://github.com/Microsoft/Virtualization-Documentation/tree/master/hyperv-tools/Convert-WindowsImage
    Import-Module Convert-WindowsImage

    Convert-WindowsImage -WorkingDirectory "C:\vm" -SourcePath $WimFile -SizeBytes 127GB -DiskLayout BIOS -ExpandOnNativeBoot:$false -Edition Standard

    # Got this error, looks like it means boot wasn't set up
    # Convert-WindowsImage : The variable '$systemDrive' cannot be retrieved because it has not been set.
    # At C:\Users\Jim.AD\Documents\git\MidFredVmPlay\NewWinVM.ps1:10 char:1
    # + Convert-WindowsImage -WorkingDirectory "C:\vm" -SourcePath $WimFile - ...
    # + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #     + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    #     + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Convert-WindowsImage
}

function New-MfVm {
    New-VM -Name Win2012 -VHDPath C:\vm\Win2012r2.vhd -MemoryStartupBytes 1024mb
    Get-VM win2012 | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName Internal-ICS-NAT
}

# New-MfVhd $WimFile
# New-MfVm
