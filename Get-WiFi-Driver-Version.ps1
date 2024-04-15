## Gets the WLAN adaptor name and driver version, saves to Ninja attributes
$drivername = ((netsh wlan show drivers) -Match '^\s+Driver' -Replace '^\s+Driver\s+:\s+','')
$driverversion = ((netsh wlan show drivers) -Match '^\s+Version' -Replace '^\s+Version\s+:\s+','')

Write-Host "Adaptor $drivername"
Write-Host "Version $driverversion"
Ninja-Property-Set wlanDriverVersion $driverversion
Ninja-Property-Set wlanAdaptorName $drivername
