param (
    # $WimFile = "C:\temp\deleteme\sources\install.wim"
    $WimFile = "D:\sources\install.wim"
)

function New-MfVhd {
    param (
        [Parameter(Mandatory=$true)]
        $WimFile
    )
    # From https://github.com/Microsoft/Virtualization-Documentation
    # Specifically https://github.com/Microsoft/Virtualization-Documentation/tree/master/hyperv-tools/Convert-WindowsImage
    # Import-Module Convert-WindowsImage
    # Now using my own fork to fix the -DiskLayout BIOS problem
    Import-Module C:\Users\Jim.AD\Documents\git\Virtualization-Documentation\hyperv-tools\Convert-WindowsImage -Force

    # NOTE: I kept getting the following error; it turns out my iso file was corrupt. Its SHA1 signature didn't match MSDN
    #   Convert-WindowsImage : The file or directory is corrupted and unreadable. (Exception from HRESULT: 0x80070570)
    # Convert-WindowsImage -WorkingDirectory "C:\vm" -SourcePath $WimFile -SizeBytes 127GB -DiskLayout BIOS -ExpandOnNativeBoot:$false -Edition Standard
    Convert-WindowsImage -WorkingDirectory "C:\vm" -SourcePath $WimFile -SizeBytes 127GB -DiskLayout BIOS -ExpandOnNativeBoot:$false -Edition Standard

    # Got this error, looks like it means boot wasn't set up
    # Convert-WindowsImage : The variable '$systemDrive' cannot be retrieved because it has not been set.
    # At C:\Users\Jim.AD\Documents\git\MidFredVmPlay\NewWinVM.ps1:10 char:1
    # + Convert-WindowsImage -WorkingDirectory "C:\vm" -SourcePath $WimFile - ...
    # + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #     + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    #     + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Convert-WindowsImage

    # Convert-WindowsImage -VhdPath c:\vm\Win2012r2.vhdx -SourcePath $WimFile -SizeBytes 127GB -DiskLayout UEFI -ExpandOnNativeBoot:$false -Edition Standard

}

# Using for reference: http://www.tomsitpro.com/articles/hyper-v-powershell-cmdlets,2-779.html
function New-MfVm {
    New-VM -Name Win2012 -VHDPath C:\vm\9600.17415.amd64fre.winblue_r4.141028-1500_Server_ServerStandard_en-US.vhd -MemoryStartupBytes 1024mb
    Get-VM win2012 | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName Internal-ICS-NAT
}

# New-MfVhd $WimFile
# New-MfVm
