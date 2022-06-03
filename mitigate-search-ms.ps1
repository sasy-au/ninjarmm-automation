#######################################################################
## Script to disable the search-ms protocol to mitigate vulnerability #
## v1.0                                                               #
## Specialised Assistance School for Youth                            #
#######################################################################

$flag = $args[0]
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR | Out-Null
if ($flag -eq 'undo')
{
    # Check that key was renamed
    if (Test-Path -Path "HKCR:\search-ms_bak") {
        # Undo change
        write-host "Restoring search-ms registry keys..."
        Rename-Item -Path "HKCR:\search-ms_bak" -newName "search-ms" | Out-Null
        Set-Item -Path "HKCR:\search-ms" -Value "URL:search-ms" | Out-Null
        write-host "Completed."
    } else {
        write-host "search-ms backup registry key not found."
    }
}
else {
    if (Test-Path -Path "HKCR:\search-ms") {
        #Apply mitigation
        write-host "Rename search-ms registry keys..."
        Set-Item -Path "HKCR:\search-ms" -Value "URL:search-ms_bak" | Out-Null
        Rename-Item -Path "HKCR:\search-ms" -newName "search-ms_bak" | Out-Null
        write-host "Completed."
    } else {
        write-host "search-ms registry key not found."
    }
}
