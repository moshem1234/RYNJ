Function Profile {code $PsHome\profile.ps1}
Function Edit {code C:\Scripts}
Function Scripts {code C:\Scripts}
Function GitHub {code C:\Scripts-Github}
Function Results {code C:\Results}
Function Log {notepad C:\Users\mmoskowitz\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt}
Function Quit {exit}
Set-Alias Q Quit
Set-Alias C Clear-Host
Set-Alias -Name IsItConnected -Value ConnectionTest
Set-Alias Room Get-RoomNumber
Set-Alias M-I Mass-Invoke
Set-Alias Hist Log
Function New {
	param(
		[string]$FileName
	)
	Copy-Item -Path "C:\Scripts\Template.ps1" -Destination "C:\Scripts\$FileName.ps1"
}
Function User {
	param (
		[string]$PCName
	)
	Invoke-Command -ComputerName $PCName -ScriptBlock {query user}
}
Function Update {
	Write-Host "Checking for Windows Updates" -ForegroundColor DarkBlue
	Get-WindowsUpdate
	Write-Output ""
	Write-Output ""
	Write-Host "Checking for Program Updates" -ForegroundColor DarkBlue
	winget upgrade
	Write-Output ""
	Write-Output ""
	Write-Host "Checking for Dell Updates" -ForegroundColor DarkBlue
	dcu-cli /scan
}
Function Colors {
	$Colors = @("Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")
	$Colors | ForEach-Object {Write-Host "$_" -ForegroundColor $_}
	$Colors | ForEach-Object {Write-Host "$_" -BackgroundColor $_}
}
Function MSYS {
	param (
		[String]$NewVersion
	)
	Set-ItemProperty -Path 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{89517838-4c5a-46f1-8d74-d529cee1b19b}' -Name 'DisplayVersion' -Value $NewVersion

}
Function Discord {
	param (
		[String]$NewVersion
	)
	Set-ItemProperty -Path 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Discord' -Name 'DisplayVersion' -Value $NewVersion
}
Function SleepCount($S){
	$S0 = $S
Do {
	$M = [Math]::Floor($S / 60)
	$MS = $S % 60
	If ($PSVersionTable.PSVersion.Major -EQ 7) {Write-Progress -SecondsRemaining $s -Activity "Sleeping" -Status "$M Minutes, $MS Seconds Remaining: " -PercentComplete ((($S0-$S)/$S0) * 100) -Id 1}
	Else {Write-Progress -SecondsRemaining $s -Activity "Sleeping" -Status "Time Remaining: " -PercentComplete ((($S0-$S)/$S0) * 100) -Id 1}
	$S--
	Start-Sleep -Seconds 1
}
Until ($S -eq 0)
Write-Progress -Activity "Sleeping" -Completed -Id 1
}