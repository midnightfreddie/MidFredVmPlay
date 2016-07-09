
function New-MfVhd {
    param (
        $SourcePath = "D:\sources\install.wim",
        $Edition = "SERVERSTANDARDCORE",
        $VhdPath = "C:\vm\servercore2012r2",
        $SizeBytes = "127GB",
        $DiskLayout = "BIOS",
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
    Convert-WindowsImage @PSBoundParameters

}

# Using for reference: http://www.tomsitpro.com/articles/hyper-v-powershell-cmdlets,2-779.html
function New-MfVm {
    New-VM -Name Win2012 -VHDPath C:\vm\9600.17415.amd64fre.winblue_r4.141028-1500_Server_ServerStandard_en-US.vhd -MemoryStartupBytes 1024mb
    Get-VM win2012 | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName Internal-ICS-NAT
}

# New-MfVhd
# New-MfVm
