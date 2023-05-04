# ninjarmm-automation
Automation for NinjaRMM

Some scripts which we have produced which others may find useful.

## Monitor-GravityZone.vbs - Monitoring Bitdefender GravityZone

If you have an existing annual license for GravityZone you cannot currently integrate into NinjaRMM so a monitoring script is needed. Currently written in vbscript, eventually we will re-write in powershell. Monitors the status of GravityZone, return codes indicate status:
```
0 - Up to date - Real time scanning running (good)
1 - Not up to date - Real time scanning running (warning)
2 - Bitdefender or Real time scanning not running (critical)
3 - Not installed (critical)
6 - Could not run script - error determining version or could not download
```

## Bitlocker-Status.ps1 - Monitoring Bitlocker status

The limitation in the built in monitoring of Bitlocker in Ninja is that it isn't very granular, nor can it report on if Bitlocker is enabled but just needs a reboot to begin the encryption process. Return codes indicate status:
```
0 - Enabled and running
0 - Encryption in progress
1 - Suspended (encrypted but key in the clear)
2 - Enabled but key not backed up (requires custom field)
3 - Reboot required to begin encryption
4 - Not enabled and decrypted
5 - Drive not ready to be encrypted
6 - TPM not ready
```

## Monitor-Windows-License-Status.ps1 - Monitoring Windows License status

Occasional a windows machine will not activate, or the OEM key will not be injected by the reseller, or something. This script can report the status of windows license. If the status can't be determined, it returns 7 plus the embedded OEM key if present. (OA3XOriginalProductKey)

Output:
```
0=Unlicensed
1=Licensed
2=OOBGrace
3=OOTGrace
4=NonGenuineGrace
5=Notification
If 5=Notification is returned, an additional check if the cause is VOLUME_KMSCLIENT activation type
6=ExtendedGrace
7=OEMkey-[key]
```

## Install-FSLogix-Apps.ps1 - Downloads and installs FSLogix Apps

Checks if installed, and compares the currently installed version number to the version downloaded from Microsoft's short link: https://aka.ms/fslogix/download
