## Gets the WLAN driver version and saves to a Ninja attribute
$driverversion = ((netsh wlan show drivers) -Match '^\s+Version' -Replace '^\s+Version\s+:\s+','')

Write-Host "Version $driverversion"
Ninja-Property-Set wlanDriverVersion $driverversion
