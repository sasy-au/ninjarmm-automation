' Bitdefender GravityZone Monitoring Script by David Beaumont
' Specialised Assistance School for Youth
' v0.1 5 Dec 2021
' Adapted from part of AVStatus.vbs by Chris Reid 

' Return codes:
' 0 - Up to date - Real time scanning running (good)
' 1 - Not up to date - Real time scanning running (warning)
' 2 - Bitdefender or Real time scanning not running (critical)
' 3 - Not installed (critical)
' 4 - Reserved for future enhancement: Other AV running (error)
' 5 - Reserved for future enhancement: Could not authenticate download (error)
' 6 - Could not run script - error determining version or could not download

' Define folder for download, do not add a trailing \
' WScript.CreateObject("Scripting.FileSystemObject").GetSpecialFolder(2) is temp folder (0 is windows, 1 is system, 2 is temp)
RMMfolder = WScript.CreateObject("Scripting.FileSystemObject").GetSpecialFolder(2)

' Todo: If not installed, check if there is a running AV and if up to date

' Output
Set WshShell = WScript.CreateObject("WScript.Shell")
Set output = Wscript.stdout

' WinHttp object for downloads
Set objXMLHTTP = CreateObject("WinHttp.WinHttpRequest.5.1") 

' Function to easily download a file to a location, overwriting if already existing
Function DownloadFile(strFileURL, strHDLocation)

	' Dumb but works: Determine the filename from last / in URL:
	aryFileSlash = split(strFileURL, "/")
	intSlashes = Ubound(aryFileSlash)
	strFileName = aryFileSlash(intSlashes)
    ' Sourced from: https://serverfault.com/questions/29707/download-file-from-vbscript
    ' Fetch the file
    
    output.writeline "- Will attempt to download the following file: " & strFileURL
	output.writeline "- To the following file name: " & strFileName
    output.writeline "- The file will be stored at the following path: " & strHDLocation
    Set objXMLHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")
	objXMLHTTP.open "GET", strFileURL, false
    objXMLHTTP.send()

    If objXMLHTTP.Status = 200 Then
        Set objADOStream = CreateObject("ADODB.Stream")
        objADOStream.Open
        objADOStream.Type = 1 'adTypeBinary

        objADOStream.Write objXMLHTTP.ResponseBody
        objADOStream.Position = 0    'Set the stream position to the start

        Set objFSO = Createobject("Scripting.FileSystemObject")
        If objFSO.FileExists(strHDLocation & strFileName) Then 
            objFSO.DeleteFile strHDLocation & strFileName
            Set objFSO = Nothing
        End If
            
        objADOStream.SaveToFile strHDLocation & strFileName
        objADOStream.Close
        Set objADOStream = Nothing
      
        DownloadFile = TRUE
    
    Else
        DownloadFile = FALSE
    End If

    Set objXMLHTTP = Nothing

End Function

' Universal objFSO
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get current RMM SDK version from http://download.bitdefender.com/SMB/RMM/Tools/Win/latest.dat
if DownloadFile("http://download.bitdefender.com/SMB/RMM/Tools/Win/latest.dat", RMMfolder & "\") = True then
	Set objFSO = CreateObject("Scripting.FileSystemObject")

	Set file = objFSO.OpenTextFile(RMMfolder & "\latest.dat")
	epsrmmver = file.ReadLine()

	output.writeline "- Current RMM SDK version: " & epsrmmver
	
	'Set download URL
	epsrmmdownload = "http://download.bitdefender.com/SMB/RMM/Tools/Win/" & epsrmmver & "/x64/eps.rmm.exe"
	output.writeline "- Download URL if required: " & epsrmmdownload
	
Else ' File was not downloaded
	output.writeline "Current RMM SDK version could not be determined."
	'if an existing version exists, use that. Otherwise exit
	if objFSO.FileExists(RMMfolder & "\eps.rmm.exe") then
		output.writeline "Using existing download in " & RMMfolder
	Else
		output.writeline "No existing download, exiting."
		Wscript.quit(6)
	End If
End if


' Let's see if the eps.rmm.exe file is in RMMfolder
If objFSO.FileExists(RMMfolder & "\eps.rmm.exe") Then
	output.writeline "- The Bitdefender RMM SDK is present on this device."
	'TODO: determine if version is current or not, only check once a day - https://stackoverflow.com/questions/2976734/how-to-retrieve-a-files-product-version-in-vbscript
ElseIf DownloadFile(epsrmmdownload, RMMfolder & "\") = True Then
	output.writeline "- The eps.rmm.exe file was not found in RMMfolder, but it's been successfully downloaded."
	'TODO: Check signature of download to prevent tampering
	'((Get-AuthenticodeSignature %1).Status) -eq 'Valid'
	'Read subject and compare to known good subject eg: CN = Bitdefender SRL OU = OU = DEVSUP EPSINTEGRATION O = Bitdefender SRL L = Bucharest C = RO

Else
	output.writeline "- The Bitdefender RMM SDK is not present on this device, and could not be downloaded."
	output.writeline "- Please download the Bitdefender RMM SDK from http://download.bitdefender.com/SMB/RMM/Tools/Win/ and place it in the RMMfolder folder."
	output.writeline "- Exiting the script."
	Wscript.quit(6)
End If


' Now that we know where to go to find the eps.rmm executable, check if Bitdefender is detected
' eps.rmm.exe -detect
' Exit code 0 indicates success reading info
' Output beginning with "1|" indicates installed and running. 2| is not running 0| is not installed
Set oExec = WshShell.Exec(RMMfolder & "\eps.rmm.exe -detect")
sLine = oExec.StdOut.ReadLine
if left(sLine,2) = "0|" Then
	'Not installed
	output.writeline "- Bitdefender GravityZone not installed. String returned from eps.rmm.exe -detect is: " & sLine
	Wscript.quit(3)
Elseif left(sLine,2) = "1|" Then
	'Installed and running
	EPSinstalled = true
	EPSrunning = true
	output.writeline "- Bitdefender GravityZone installed and running. String returned from eps.rmm.exe -detect is: " & sLine
Elseif left (sLine,2) = "2|" Then
	'installed and not running
	output.writeline "- Bitdefender GravityZone installed but not running. String returned from eps.rmm.exe -detect is: " & sLine
	Wscript.quit(2)
Else
	'Could not be determined
	output.writeline "Status not detected. String returned from eps.rmm.exe -detect is: " & sLine
	Wscript.quit(6)
End if


' let's determine what version of Bitdefender is installed on the device.
Set oExec = WshShell.Exec(RMMfolder & "\eps.rmm.exe -getProductVersion")
sLine = oExec.StdOut.ReadLine
			
If InStr(sLine, ".") <> 0 Then
	FormattedAVVersion = sLine
Else
	FormattedAVVersion = "Unknown"
End If
	
output.writeline "- The version of Bitdefender running on this machine is: " & FormattedAVVersion
	
' Now let's use the eps.rmm.exe to determine whether or not Bitdefender is up-to-date.
Set oExec = WshShell.Exec(RMMfolder & "\eps.rmm.exe -isUpToDate")
sLine = oExec.StdOut.ReadLine

output.writeline "- Returned value: " & sLine
output.writeline "- If 1, then Up-To-Date; if 0, BEST is not up-to-date."
		   
If sLine="1" Then
	ProductUpToDate = True
Else
	ProductUpToDate = False
End If
	
output.writeline "- Is Bitdefender up-to-date? " & ProductUpToDate
	
' Now let's use the eps.rmm.exe to determine whether or not Real-Time Scanning is enabled.
Set oExec = WshShell.Exec(RMMfolder & "\eps.rmm.exe -getFeatureStatus")
sLine = oExec.StdOut.ReadLine
			
If InStr(sLine, "FileScan.OnAccess=1") <> 0 Then
	OnAccessScanningEnabled = True
Else
	OnAccessScanningEnabled = False
End If
	
output.writeline "- Is Real Time Scanning Enabled? " & OnAccessScanningEnabled
	
	
' Return status:
If ProductUpToDate and OnAccessScanningEnabled then
	Wscript.quit(0)
elseif (not ProductUpToDate) and OnAccessScanningEnabled then
	Wscript.quit(1)
end if
