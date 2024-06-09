# $Key = Get-Content \\PC1380\Scripts\AES.key
# $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "itnotifications@rynj.org", (Get-Content \\PC1380\Scripts\ITnotificationsPW.txt | ConvertTo-SecureString -Key $Key)
$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Finding Newline Errors (3)" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		$Event4 = Get-WinEvent -ComputerName $Server -LogName "Microsoft-Windows-DeviceSetupManager/Admin" -FilterXPath "*[System[Provider[@Name='Microsoft-Windows-DeviceSetupManager'] and (EventID=301 or EventID=112 or EventID=1001)]]" -ErrorAction:SilentlyContinue | Select-Object TimeCreated, Message | Where-Object {($_.TimeCreated -GT $Yesterday) -and (($_.Message -Like "Device 'Unknown USB Device (Configuration Descriptor Request Failed)'*") -or ($_.Message -Like "Device 'Unknown USB Device (Device Descriptor Request Failed)'*"))}
		If($Event4){
			Restart-Computer -ComputerName $Server -Force
			$Errors += "$Server "
		}
	}
	$count += 1
}
If($Errors){
	# Send-MailMessage -From 'PC1380 <itnotifications@rynj.org>' -To 'Moshe <mmoskowitz@rynj.org>' -Credential $Credential -UseSSL -Subject 'Newline Board Error Detected' -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "Newline Errors (3) have been detected and the victim PCs have been restarted.
#  Restarted PCs include: $Errors" -WarningAction:SilentlyContinue
	$Date = Get-Date -Format m
	Write-Output "$Date - $Errors " | Out-File C:\Results\NewlineErrors3.txt -Append 
}
Else{
	# Send-MailMessage -From 'PC1380 <itnotifications@rynj.org>' -To 'IT <IT@rynj.org>' -Credential $Credential -UseSSL -Subject 'No Newline Board Errors' -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "The script has ran succesfully and there were no Newline errors found." -WarningAction:SilentlyContinue
}