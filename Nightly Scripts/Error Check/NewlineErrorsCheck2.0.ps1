$Key = Get-Content \\PC1380\Scripts\AES.key
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "itnotifications@rynj.org", (Get-Content \\PC1380\Scripts\ITnotificationsPW.txt | ConvertTo-SecureString -Key $Key)
$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Finding Newline Errors (2)" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		$Event4 = Get-WinEvent -ComputerName $Server -LogName "Microsoft-Windows-Kernel-PnP/Configuration" -FilterXPath "*[System[(Level=2)]]" -ErrorAction:SilentlyContinue | Select-Object TimeCreated, Message | Where-Object {($_.TimeCreated -GT $Yesterday) -and ($_.Message -Like "Device USB\VID_0000&PID_0002*")}
		If($Event4){
			Restart-Computer -ComputerName $Server -Force
			$Errors += "$Server "
		}
	}
	$count += 1
}
If($Errors){
	Send-MailMessage -From 'PC1380 <itnotifications@rynj.org>' -To 'Moshe <mmoskowitz@rynj.org>' -Credential $Credential -UseSSL -Subject 'Newline Board Error Detected' -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "Newline Errors (2) have been detected and the victim PCs have been restarted.
Restarted PCs include: $Errors" -WarningAction:SilentlyContinue
}
Else{
	# Send-MailMessage -From 'PC1380 <itnotifications@rynj.org>' -To 'IT <IT@rynj.org>' -Credential $Credential -UseSSL -Subject 'No Newline Board Errors' -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "The script has ran succesfully and there were no Newline errors found." -WarningAction:SilentlyContinue
}