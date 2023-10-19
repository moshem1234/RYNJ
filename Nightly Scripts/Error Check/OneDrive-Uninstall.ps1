Get-ScheduledTask | Where-Object 'TaskName' -Like '*onedrive*' | Unregister-ScheduledTask -Confirm:$False

winget uninstall OneDriveSetup.exe --accept-source-agreements | Out-Null
winget uninstall Microsoft.OneDrive --accept-source-agreements | Out-Null
Remove-Item 'C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk' -ErrorAction:SilentlyContinue
# Write-Verbose $Blank

Set-Location "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
$Reg = Get-ChildItem | Select-Object Name
ForEach ($Key in $Reg){
	If ($Key -like "*OneDrive*"){
		$Uninstall = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe | Select-Object UninstallString
		$UninstallString = $Uninstall.UninstallString
		$UninstallString = $UninstallString.Replace("/uninstall","")
		$UninstallString = $UninstallString.Replace("/allusers","")
		$UninstallString = $UninstallString.Replace("     ","")
		$UninstallString = $UninstallString.Replace("OneDriveSetup.exe","")
		$UninstallString = $UninstallString.Replace("C:\Program Files\Microsoft OneDrive\","")
		hostname
		# Write-Output $UninstallString
		Set-Location "C:\Program Files\Microsoft OneDrive\"
		Set-Location $UninstallString
		./OneDriveSetup.exe /uninstall /allusers
	}
}

cmd -/c %systemroot%\SysWOW64\OneDriveSetup.exe /uninstall /allusers