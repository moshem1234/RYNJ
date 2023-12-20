Param (
	[String]$PC
)

If ($PC) {
	Write-Host "Creating Update Job on $PC" -ForegroundColor Cyan
	Invoke-WUJob -ComputerName $PC -Script {Install-WindowsUpdate -AcceptAll -AutoReboot} -Confirm:$False -RunNow -Force
}
Else {
	Write-Error "No PC Specified"
}