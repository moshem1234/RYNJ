$Old = Get-Content \\PC1380\Results\PrintersNotReady.txt | Out-String
$Old2 = $Old.Trim()
$Time = Get-Date
$Status = Get-Printer | Select-Object Name, PrinterStatus | Where-Object -FilterScript {($_.PrinterStatus -NotContains 'Normal') -and ($_.Name -NotLike '*YNJPRINT*') -and ($_.PrinterStatus -NotContains 'TonerLow') -and ($_.PrinterStatus -NotContains 'PaperOut') -and ($_.PrinterStatus -NotContains 'NoToner') -and ($_.PrinterStatus -NotContains 'Busy') -and ($_.PrinterStatus -NotContains 'Printing')} | Out-String
$Status2 = $Status.Trim()

If($Old2 -ne $Status2){
	Send-MailMessage -From 'Print Management <scanner@rynj.org>' -To 'Moshe <mmoskowitz@rynj.org>' -Subject "Printers Not Ready ($Time)" -SmtpServer 'smtp-relay.gmail.com' -Port 25 -Credential $Credential -UseSSL -body "$Status"
	Set-Content \\PC1380\Results\PrintersNotReady.txt -Value "$Status"
}
