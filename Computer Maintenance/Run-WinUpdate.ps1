$UpdatePCs = Detect-WinUpdate -ToRun

Write-Progress -Activity "Running Windows Updates"
ForEach ($Server in $UpdatePCs) {
	Write-Host "Creating Windows Update Job on $Server" -ForegroundColor Magenta
	Invoke-WUJob -ComputerName $Server -Script {Install-WindowsUpdate -AcceptAll -AutoReboot} -Confirm:$False -RunNow -Force
}
Write-Progress -Activity "Running Windows Updates" -Completed
