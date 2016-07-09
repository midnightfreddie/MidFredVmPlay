
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
    # Import-Module Convert-WindowsImage
    # Now using my own fork to fix the -DiskLayout BIOS problem
    Import-Module C:\Users\Jim.AD\Documents\git\Virtualization-Documentation\hyperv-tools\Convert-WindowsImage -Force

    # NOTE: I kept getting the following error; it turns out my iso file was corrupt. Its SHA1 signature didn't match MSDN
    #   Convert-WindowsImage : The file or directory is corrupted and unreadable. (Exception from HRESULT: 0x80070570)
    # NOTE: To find the Editions, run the following. -Edition can either match the last of the name or be the index number
    #  dism /get-imageinfo /imagefile:path/to/wimfile.wim
    # Convert-WindowsImage -VhdPath $VhdPath -WorkingDirectory "C:\vm" -SourcePath $WimFile -SizeBytes 127GB -DiskLayout BIOS -ExpandOnNativeBoot:$false -Edition $Edition
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
    # Must be Gen 2 to boot UEFI from vhdx
    New-VM -Name Win2012 -VHDPath C:\vm\servercore2012r2.vhdx -MemoryStartupBytes 1024mb -Generation 2
    Get-VM win2012 | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName Internal-ICS-NAT
}

# New-MfVhd
# New-MfVm
