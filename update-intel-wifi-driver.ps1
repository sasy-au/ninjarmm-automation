# Install the specified inf driver(s) from an archive which contains .inf based drivers

# Current URL to download the "Wi-Fi Drivers for IT Administrators" is:
# https://www.intel.com/content/www/us/en/download/18231/intel-proset-wireless-software-and-wi-fi-drivers-for-it-administrators.html

# Notes: When installing Intel WiFi drivers, it is recommended to install the matching Bluetooth
#        drivers at the same time.
#
#        This is based on SMB transfer and must be done as a user with access to the share.
#        
#        The script can be adapted to use Start-BitsTransfer instead to pull from an internet URL but
#        as BITS can fail, it should always be enclosed in a try/catch and use Invoke-WebRequest
#        if BITS fails. (it is just slower)

<# try {
    # Attempt to download using Start-BitsTransfer
    Start-BitsTransfer -Source $src -Destination $zip -RetryInterval 60
} catch {
    Write-Host "BITS failed, attemptig Invoke-WebRequest instead."
    Invoke-WebRequest $src -OutFile $zip
} #>

# Locations
$src = "[network path to driver zip]"
$dst = Join-Path -Path $env:TEMP -ChildPath "inftemp"
$zip = Join-Path $env:temp -childpath (split-path $src -leaf)

# Copy the drivers to the local machine
Write-Host "Copying $src to $zip."
Copy-Item -Path $src -Destination $env:TEMP

# Unzip
Write-Host "Expanding $zip to $dst."
Expand-Archive -Path $zip -DestinationPath $dst -Force

# Delete zip
Write-Host "Deleting $zip."
Remove-Item $zip -Force

# Use pnputil.exe to install driver
Write-Host "Running PnPUtil: pnputil.exe ""/add-driver $dst\*.inf /install"""
& "pnputil.exe" "/add-driver" "$dst\*.inf" "/install"

# Wait 20 seconds for completion then delete folder
Start-Sleep -Seconds 20
Remove-Item $dst -Recurse -Force
