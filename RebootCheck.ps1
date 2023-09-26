$PCs = Get-Content -Path '\\PC1380\Scripts\ClassroomPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Checking Tasks" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		# Write-Output $Server
		$Task = Invoke-Command -ComputerName $Server -ScriptBlock {Get-ScheduledTaskInfo 'Weekly Reboot' -ErrorAction:SilentlyContinue | Select-Object LastRunTime | Where-Object LastRunTime -NotLike '11/30/1999*'}
		If ($NULL -NE $Task){
			Write-Output "$Server not rebooted correctly. Restarting..."
			Restart-Computer -ComputerName $Server -Force
			$Errors += "$Server "
		}
	}
	Else{
	}
	$count += 1
}

If($NULL -NE $Errors){
	Send-MailMessage -From 'PC1380 <itnotifications@rynj.org>' -To 'Moshe <mmoskowitz@rynj.org>' -Credential $Credential -UseSSL -Subject 'Reboot Error Detected' -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "Detected PCs include: $Errors" -WarningAction:SilentlyContinue
}
