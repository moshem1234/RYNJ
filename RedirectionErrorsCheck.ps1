$StartDate =  Get-Date -Date 9/22
$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt

ForEach ($Server in $PCs) {
	Write-Progress -Activity "Checking Logs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		$Var += Get-WinEvent -ComputerName $Server -LogName "Application" -FilterXPath "*[System[Provider[@Name='Microsoft-Windows-Folder Redirection'] and (Level=1  or Level=2 or Level=5)]]" -ErrorAction SilentlyContinue | Where-Object -FilterScript {($_.TimeCreated -GT $StartDate)} | Select-Object @{name='ComputerName'; expression={"$Server"}}, TimeCreated, Message | Out-String
	}
	$count += 1
}

If ($NULL -ne $Var){
	Send-MailMessage -From "Moshe's PC <itnotifications@rynj.org>" -To '<mmoskowitz@rynj.org>' -Subject "Redirection Errors Detected" -Credential $Credential -UseSSL -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "$Var" -WarningAction:SilentlyContinue
}