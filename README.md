# midightFreddie VM Play
Trying to

- Wean myself off of the Hyper-V GUI
- Deploy (a) functional server(s) without ever connecting via RDP or vmconnect

This code is still very rough and not for general use.

## Notes

- Client machines (Win7/8/10) will need Remote Server Administration Tools installed
- UEFI boot in VMs supported only in generation 2 VMs, in Server 2012 **R2** and later or **64-bit** Windows 8 or later
- I'm developing this on a Windows 10 box with Hyper-V and intend to deploy to Hyper-V Server 2012 R2 when I have it all sorted out
- 

## Lessons Learned

- **Verify source file integrity** - At first I kept getting the error in the following quote after the VHD file appeared to be complete. I finally thought to get the file hash from MSDN and found my ISO had the wrong hash code. Powershell 4 and later have `Get-Filehash -Encoding SHA1 path/to/iso`. In previous versions, a downloadable exe or a .NET assembly can be used to verify the file. 

    > Convert-WindowsImage : The file or directory is corrupted and unreadable. (Exception from HRESULT: 0x80070570)

- Found a bug in `Convert-WindowsImage` when using `-DiskLayout BIOS`, fixed and submitted pull request. Decided to use UEFI, anyway.
- UEFI boot in Hyper-V requires a Generation 2 VM: `New-Vm -Generation 2` or else it will fail to boot properly.
- To list the editions available in a wim file for the `-Edition` parameter: `dism /get-imageinfo /imagefile:path/to/wimfile.wim`
- Oh, djoin.exe is made to work on offline images. Why TF was I trying to get unattend.xml working? djoin.exe and DSC #FTW. I was working from [this article on unattended Nano installs](http://www.tech-coffee.net/prepare-a-vhdx-image-of-nano-server/) because I did this last year with Nano successfully. I was having trouble successfully getting it to join the domain, and I thought it was due to embedded nulls in the string making its way into the unattend.xml file. Then between troubleshooting the log files, reading how this all works and running djoin.exe in the VM to try to join the domain I realized that this only works *offline*. I'm not sure how/why Nano worked last year, but djoin works fine offline, and now I have no need for unattend.xml. I can join the domain in the vhdx before starting the VM. I can probably also stage a DSC config before starting the VM.