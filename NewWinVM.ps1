param (
    # $WimFile = "C:\temp\deleteme\sources\install.wim"
    $WimFile = "D:\sources\install.wim"
)

# From https://github.com/Microsoft/Virtualization-Documentation
# Specifically https://github.com/Microsoft/Virtualization-Documentation/tree/master/hyperv-tools/Convert-WindowsImage
Import-Module Convert-WindowsImage

Convert-WindowsImage -WorkingDirectory "C:\vm" -SourcePath $WimFile -SizeBytes 127GB -DiskLayout BIOS -ExpandOnNativeBoot:$false -Edition Standard

# Got this error, unsure yet if vhd is good
# Convert-WindowsImage : The variable '$systemDrive' cannot be retrieved because it has not been set.
# At C:\Users\Jim.AD\Documents\git\MidFredVmPlay\NewWinVM.ps1:10 char:1
# + Convert-WindowsImage -WorkingDirectory "C:\vm" -SourcePath $WimFile - ...
# + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#     + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
#     + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Convert-WindowsImage