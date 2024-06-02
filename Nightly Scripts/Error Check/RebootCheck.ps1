$PCs = ConnectionTest -Online -OutArray
Write-Progress -Activity "Running Reboot Check"
$Errors = Invoke-Command -ComputerName $PCs -ScriptBlock {
	$Server = HOSTNAME
	$Task = Get-ScheduledTaskInfo 'Weekly Reboot' -ErrorAction:SilentlyContinue | Select-Object LastRunTime | Where-Object LastRunTime -NotLike '11/30/1999*'
	If ($Task){
		Write-Host "$Server not rebooted correctly. Restarting..." -ForegroundColor Blue
		Restart-Computer -ComputerName $Server -Force
		$Server
	}
}

If($Errors){
	Send-MailMessage -From 'PC1380 <itnotifications@rynj.org>' -To 'Moshe <mmoskowitz@rynj.org>' -Credential $Credential -UseSSL -Subject 'Reboot Error Detected' -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "Detected PCs include: $Errors" -WarningAction:SilentlyContinue
}
Write-Progress -Activity "Running Reboot Check" -Completed