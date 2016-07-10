# MidFredVmPlay
Trying to wean myself off of the Hyper-V GUI

This code is still very rough and not for general use.

## Lessons Learned

- **Verify source file integrity** - At first I kept getting the error in the following quote after the VHD file appeared to be complete. I finally thought to get the file hash from MSDN and found my ISO had the wrong hash code. Powershell 4 and later have `Get-Filehash -Encoding SHA1 path/to/iso`. In previous versions, a downloadable exe or a .NET assembly can be used to verify the file. 

    > Convert-WindowsImage : The file or directory is corrupted and unreadable. (Exception from HRESULT: 0x80070570)

- Found a bug in `Convert-WindowsImage` when using `-DiskLayout BIOS`, fixed and submitted pull request. Decided to use UEFI, anyway.
- UEFI boot in Hyper-V requires a Generation 2 VM: `New-Vm -Generation 2` or else it will fail to boot properly.