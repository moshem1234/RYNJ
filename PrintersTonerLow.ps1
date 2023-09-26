$Old = Get-Content \\PC1380\Results\PrintersTonerLow.txt | Out-String
$Old2 = $Old.Trim()
$Time = Get-Date
$Status = Get-Printer | Select-Object Name, PrinterStatus | Where-Object -FilterScript {($_.PrinterStatus -Contains 'TonerLow') -and ($_.Name -NotLike '*YNJPRINT*')} | Out-String
$Status2 = $Status.Trim()

If($Old2 -ne $Status2){
	Send-MailMessage -From 'Print Management <scanner@rynj.org>' -To 'Gavriella <glerner@rynj.org>' -Cc 'Moshe <mmoskowitz@rynj.org>' -Subject "Printers With Toner Low ($Time)" -SmtpServer 'smtp-relay.gmail.com' -Port 25 -Credential $Credential -UseSSL -body "$Status"
	Set-Content \\PC1380\Results\PrintersTonerLow.txt -Value "$Status"
}
