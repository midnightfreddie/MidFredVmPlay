

# From https://github.com/Microsoft/Virtualization-Documentation
# Specifically https://github.com/Microsoft/Virtualization-Documentation/tree/master/hyperv-tools/Convert-WindowsImage
Import-Module Convert-WindowsImage

Convert-WindowsImage -WorkingDirectory "C:\vm" -SourcePath "D:\sources\install.wim" -SizeBytes 127GB -DiskLayout BIOS -ExpandOnNativeBoot:$false -Edition Standard