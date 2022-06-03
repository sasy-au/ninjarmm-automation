######################################################################
## Script to disable the ms-msdt protocol to mitigate CVE-2022-30190 #
## v1.0                                                              #
## Specialised Assistance School for Youth                           #
######################################################################

$flag = $args[0]
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR | Out-Null
if ($flag -eq 'undo')
{
    # Check that key was renamed
    if (Test-Path -Path "HKCR:\ms-msdt_bak") {
        # Undo change
        write-host "Restoring ms-msdt registry keys..."
        Rename-Item -Path "HKCR:\ms-msdt_bak" -newName "ms-msdt" | Out-Null
        Set-Item -Path "HKCR:\ms-msdt" -Value "URL:ms-msdt" | Out-Null
        write-host "Completed."
    } else {
        write-host "ms-msdt backup registry key not found."
    }
}
else {
    if (Test-Path -Path "HKCR:\ms-msdt") {
        #Apply mitigation
        write-host "Rename ms-msdt registry keys..."
        Set-Item -Path "HKCR:\ms-msdt" -Value "URL:ms-msdt_bak" | Out-Null
        Rename-Item -Path "HKCR:\ms-msdt" -newName "ms-msdt_bak" | Out-Null
        write-host "Completed."
    } else {
        write-host "ms-msdt registry key not found."
    }
}
