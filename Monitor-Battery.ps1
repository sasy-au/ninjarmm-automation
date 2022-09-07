## Battery Monitor Script from CyberDrain with slight modifications
## https://www.cyberdrain.com/monitoring-with-powershell-monitoring-battery-health/

## Accepts one argument which should be an integer of if to alert if any battery health is below that percentage
## eg: 80 will alert if any battery full charge capacity is less than 80 percent of design capacity

## Example output:
# Monitor for battery health less than 80 percent', evaluation script 'Battery Monitor' with output 'Battery life report saved to file path C:\windows\system32\batteryreport.xml.
# The battery health is less than expect. The battery was designed for 45030 but the maximum charge is 35990. The battery info is Primary

$AlertPercent = $args[0]

& powercfg /batteryreport /XML /OUTPUT "batteryreport.xml"
Start-Sleep 1
[xml]$Report = Get-Content "batteryreport.xml"

$BatteryStatus = $Report.BatteryReport.Batteries.ChildNodes |
ForEach-Object {
  [PSCustomObject]@{
    DesignCapacity = $_.DesignCapacity
    FullChargeCapacity = $_.FullChargeCapacity
    CycleCount = $_.CycleCount
    Id = $_.id
  }
}

if (!$BatteryStatus) {
Write-Host "This device does not have batteries, or we could not find the status of the batteries."
}

foreach ($Battery in $BatteryStatus) {
    if ([int64]$Battery.FullChargeCapacity * 100 / [int64]$Battery.DesignCapacity -lt $AlertPercent) {
        Write-host "The battery health is less than expect. The battery was designed for $($battery.DesignCapacity) but the maximum charge is $($Battery.FullChargeCapacity). The battery info is $($Battery.id)"

    } else {
        Write-host "The battery health above $AlertPercent percent. The battery was designed for $($battery.DesignCapacity) and the maximum charge is $($Battery.FullChargeCapacity). The battery info is $($Battery.id)"
    }

}
