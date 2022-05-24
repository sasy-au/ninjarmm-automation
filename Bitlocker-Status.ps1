###############################################################
## Script to return current status of Bitlocker on the system #
## v1.0                                                       #
## Specialised Assistance School for Youth                    #
###############################################################
## Return codes:
## 0 - Enabled and running
## 0 - Encryption in progress
## 1 - Suspended (encrypted but key in the clear)
## 2 - Enabled but key not backed up
## 3 - Reboot required to begin encryption
## 4 - Not enabled and decrypted
## 5 - Drive not ready to be encrypted
## 6 - TPM not ready
###############################################################
# NOTE: Return code 2 is dependant on a custom field to test
#       if the key has been backed up. Uncomment to use.
###############################################################
# Order of tests is based on amount of time taken to process
# and which status takes precidence
# Enabled and running is quickest, WMI queries are slowest
###############################################################

# Get system drive bitlocker object
$SysDriveBitlocker =(Get-BitLockerVolume -MountPoint $ENV:SystemDrive -ErrorAction SilentlyContinue)

# Enabled but key not backed up
#if (($SysDriveBitlocker.ProtectionStatus -eq 'On') -and -not(Ninja-Property-Get bitlockerRecoveryKeyLastBackup -ErrorAction SilentlyContinue)) {
#    Write-Host "Bitlocker enabled but key hasn't been backed up."
#    Exit 2
#}

# Enabled and running
if ($SysDriveBitlocker.ProtectionStatus -eq 'On') {
    Write-Host "Bitlocker enabled."
    Exit 0
}
# Encyption in progress
if ($SysDriveBitlocker.VolumeStatus -eq "EncryptionInProgress") {
    Write-Host "Drive currently being encrypted...$($SysDriveBitlocker.EncryptionPercentage)"
    Exit 0
}

# Reboot required
$managebdestatus = &"C:\Windows\System32\manage-bde.exe" -status;
if ($managebdestatus -like "*Restart the computer*") {
    write-host "Bitlocker is already enabled but not active until a reboot."
    exit 3
}

# Encrypted but suspended (FullyEncrytped but ProtectionStatus off)
if (($SysDriveBitlocker.ProtectionStatus -eq 'Off') -and ($SysDriveBitlocker.VolumeStatus -eq "FullyEncrypted")) {
    Write-Host "Bitlocker suspended. Drive is encrypted but key is unprotected."
    Exit 1
}


# Not enabled and not encrypted
if ($SysDriveBitlocker.VolumeStatus -eq "FullyDecrypted") {
    write-host "Bitlocker is off and drive is not encrypted."
    exit 4
}

# Drive is not prepared for bitlocker
if (!$SysDriveBitlocker) {
    write-host "Drive is not ready for Bitlocker."
    Exit 5
}

# TPM not ready
if ($null -eq (Get-WmiObject -Namespace root/cimv2/security/microsofttpm -Class Win32_TPM | where-object {($_.IsActivated_InitialValue -eq $true) -and ($_.IsEnabled_InitialValue -eq $true)})) {
    # TPM is not ready for Bitlocker. IsActivated_InitialValue and IsEnabled_InitialValue must be true
    Write-Host "TPM not ready for BitLocker. Exiting."
    Exit 6
}