$PCs = ConnectionTest -Online -OutArray

Write-Progress -Activity "Querying Hard Drive Space"
$Var = Invoke-Command -ComputerName $PCs -ScriptBlock {
	wmic logicaldisk Get freespace ',' Caption /FORMAT:csv | Out-File 'C:\Windows\temp\disk.csv'
	$Space = Import-CSV -Path 'C:\Windows\temp\disk.csv' -Header Node,Caption,FreeSpace | Where-Object Caption -eq 'C:' | Select-Object FreeSpace | Format-Table -hide | Out-String
	$Space /= 1024
	$Space /= 1024
	$Space /= 1024
	If ($Space -lt 50){
		Write-Output "$env:ComputerName under 50 GB"
	}
}
If ($Var){
	Send-MailMessage -From "Moshe's PC <itnotifications@rynj.org>" -To '<IT@rynj.org>' -Subject "Low Disk Space Detected" -Credential $Credential -UseSSL -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "$Var" -WarningAction:SilentlyContinue
}
Write-Progress -Activity "Querying Hard Drive Space" -Completed