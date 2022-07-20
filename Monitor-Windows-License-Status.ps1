# Windows License Status Script by David Beaumont
# Specialised Assistance School for Youth
# v1.1 18 Jun 2022


#Get license status.
$license = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey } | Select-Object Description, LicenseStatus

# License status output:
# 0=Unlicensed
# 1=Licensed
# 2=OOBGrace
# 3=OOTGrace
# 4=NonGenuineGrace
# 5=Notification
# If 5=Notification is returned, an additional check if the cause is VOLUME_KMSCLIENT activation type
# 6=ExtendedGrace
# 7=OEMkey-[key]

switch($license.LicenseStatus){
    0 {
        Write-Host "0=Unlicensed"
    }
    1 {
        Write-Host "1=Licensed"
    }
    2 {
        Write-Host "2=OOBGrace"
    }
    3 {
        Write-Host "3=OOTGrace"
    }
    4 {
        Write-Host "4=NonGenuineGrace"
    }
    5 {
        # Check if notification is due to VOLUME_KMSCLIENT
        $slmgr = &"C:\Windows\System32\cscript.exe" c:\windows\system32\slmgr.vbs /dli;
        if ($slmgr -like "*VOLUME_KMSCLIENT*") {
            Write-Host "VOLUME_KMSCLIENT"
        }
        Write-Host "5=Notification"
    }
    6 {
        Write-Host "6=ExtendedGrace"
    }
    default {
        Write-Host "Error determining license status, output from slmgr.vbs /dli follows"
        &"C:\Windows\System32\cscript.exe" c:\windows\system32\slmgr.vbs /dli;
        # Check for embedded product key
        $service = get-wmiObject -query 'select * from SoftwareLicensingService'
        if($service.OA3xOriginalProductKey){
            write-host "7=OEMkey-" $service.OA3xOriginalProductKey
        }else{
            Write-Host 'OEM product key not found.'
        }

    }
}
