$Var = Invoke-Command -ComputerName YNJDATA02 -ScriptBlock {
	wmic logicaldisk Get freespace ',' Caption /FORMAT:csv | Out-File 'C:\Windows\temp\disk.csv'
	$Space = Import-CSV -Path 'C:\Windows\temp\disk.csv' -Header Node,Caption,FreeSpace | Where-Object Caption -eq 'D:' | Select-Object FreeSpace | Format-Table -hide | Out-String
	$Space /= 1024
	$Space /= 1024
	$Space /= 1024
	If ($Space -lt 100){
		Write-Output "H: Drive Free Space under 100 GB"
	}
}
	If ($NULL -ne $Var){
		Send-MailMessage -From "Moshe's PC <itnotifications@rynj.org>" -To '<IT@rynj.org>' -Subject "Low H Drive Space Detected" -Credential $Credential -UseSSL -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "$Var" -WarningAction:SilentlyContinue
	}
