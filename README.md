# lggram2023speakerfix
Initialize 2023 LG Gram 16 2-in-1 speakers using hda-verbs captured from win11 qemu session

Overall procedure is documented here:
https://github.com/ryanprescott/realtek-verb-tools/wiki/How-to-sniff-verbs-from-a-Windows-sound-driver

1. build latest version of qemu (in my case version 8.1.0) with CORB logging additions in hw/vfio/common.c as shown in https://github.com/jcs/qemu/commit/7c1f83b6d700fc2733e0964a1a35383e71ecb838 and https://github.com/jcs/qemu/commit/0d2dd1d0e200f9b71c4fba2767522198630b6796 (patch.txt file in this repo)
2. lspci -nn | grep audio
   ```
   00:1f.3 Multimedia audio controller [0401]: Intel Corporation Raptor Lake-P/U/H cAVS [8086:51ca] (rev 01)
   ```
3. modify GRUB to enable binding and pass-through of audio device:
   ```
   GRUB_CMDLINE_LINUX_DEFAULT='quiet resume=UUID=2632e60e-6b09-46ca-9f7c-69ac2573c44b loglevel=3 pci-stub.ids=8086:51ca iommu=pt intel_iommu=on'
   ```
4. build new grub file:
   `sudo grub-mkconfig -o /boot/grub/grub.cfg`
5. reboot
6. run bind script:
   ```
   sudo ./vfio-bind.sh 0000:00:1f.0 0000:00:1f.3 0000:00:1f.4 0000:00:1f.5
   ```
7. start win11VM:
   ```
   ./startwin11vm.sh > qemu-output.txt 2>&1
   ```
8. in windows, you should hear sound, play with audio control to generate verbs.
9. shutdown windows, qemu should then quit and view qemu-output.txt to see if any CORB data was captured.
10. git clone https://github.com/ryanprescott/realtek-verb-tools
11. use realtek tools to extract clean-verbs.txt file
12. edit grub to put back original kernel params, run grub-mkconfig, and reboot
13. play long youtube video that has sound from browser, then use realtek tools to apply verbs and ctrl-C once you hear sound. Take note of line number. All verbs after that line are not needed, copy minimum number of lines to necessary-verbs.txt
14. until kernel patch makes it's way upstream, simple run realtek apply verb script upon login to initialize speakers.

NOTE: I've found that with a warm reboot, the internal speakers remains initialized. only during a hard cold restart does it require initialization with the captured verbs.

## OTHER LINKS
https://bugzilla.kernel.org/show_bug.cgi?id=212041
https://wiki.archlinux.org/title/LG_Gram_16_2-in-1_2023
https://github.com/thesofproject/linux/issues/4363
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1851518
https://superuser.com/questions/1627065/ubuntu-20-04-lts-no-sound-on-lg-gram-2021-a-lot-of-troubleshooting-attempted
https://github.com/Teetoow/SamsungGalaxyBook12/tree/main/ALC298

## Miscellaneous info
```
lspci -kvv

00:1f.3 Multimedia audio controller: Intel Corporation Raptor Lake-P/U/H cAVS (rev 01)
	DeviceName: Onboard - Sound
	Subsystem: LG Electronics, Inc. Device 0496
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 32, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 203
	IOMMU group: 14
	Region 0: Memory at 603d190000 (64-bit, non-prefetchable) [size=16K]
	Region 4: Memory at 603d000000 (64-bit, non-prefetchable) [size=1M]
	Capabilities: <access denied>
	Kernel driver in use: sof-audio-pci-intel-tgl
	Kernel modules: snd_hda_intel, snd_sof_pci_intel_tgl
```
