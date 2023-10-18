$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
$Date = (Get-Date) - (New-TimeSpan -Day 1)

ForEach ($Server in $PCs) {
	Write-Progress -Activity "Checking Logs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		$Var += Get-WinEvent -ComputerName $Server -LogName "Application" -FilterXPath "*[System[Provider[@Name='Group Policy Applications' or @Name='Group Policy Client' or @Name='Group Policy Device Settings' or @Name='Group Policy Drive Maps' or @Name='Group Policy Environment' or @Name='Group Policy Files' or @Name='Group Policy Local Users and Groups' or @Name='Group Policy Power Options' or @Name='Group Policy Printers' or @Name='Group Policy Registry' or @Name='Group Policy Scheduled Tasks' or @Name='Group Policy Services' or @Name='GroupPolicy' or @Name='Microsoft-Windows-GroupPolicy'] and (Level=1 or Level=2 or Level=3 or Level=5)]]" | Select-Object @{name='ComputerName'; expression={"$Server"}},TimeCreated,Message | Where-Object -FilterScript {($_.TimeCreated -GT $Date) -and ($_.Message -NOTLIKE "*0x80070047 No more connections can be made to this remote computer at this time because there are already as many connections as the computer can accept.*")} | Format-Table -AutoSize -Wrap | Out-String
		$Var += Get-WinEvent -ComputerName $Server -LogName "Microsoft-Windows-GroupPolicy/Operational" -FilterXPath "*[System[(Level=0 or Level=1 or Level=3 or Level=5)]]" -ErrorAction SilentlyContinue | Select-Object @{name='ComputerName'; expression={"$Server"}},TimeCreated,Level,Message | Where-Object -FilterScript {($_.TimeCreated -GT $Date)} | Format-Table -AutoSize -Wrap | Out-String
	}
	$count += 1
}

If ($NULL -ne $Var){
	Send-MailMessage -From "Moshe's PC <itnotifications@rynj.org>" -To '<mmoskowitz@rynj.org>' -Subject "Group Policy Errors Detected" -Credential $Credential -UseSSL -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "$Var" -WarningAction:SilentlyContinue
}
