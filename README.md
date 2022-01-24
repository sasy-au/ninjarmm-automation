# ninjarmm-automation
Automation for NinjaRMM

Some scripts which we have produced which others may find useful.

## Monitor-GravityZone.vbs - Monitoring Bitdefender GravityZone

Currently written in vbscript, eventually we will re-write in powershell. Montiors the status of GravityZone, return codes indicate status:
```0 - Up to date - Real time scanning running (good)
1 - Not up to date - Real time scanning running (warning)
2 - Bitdefender or Real time scanning not running (critical)
3 - Not installed (critical)
6 - Could not run script - error determining version or could not download
```
