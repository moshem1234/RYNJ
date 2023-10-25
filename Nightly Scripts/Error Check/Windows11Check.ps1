$PCs = Get-Content -Path '\\PC1380\Scripts\AllPCs.txt'

ForEach ($Server in $PCs) {
	Write-Progress -Activity "Checking PCs (Windows 11)" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Invoke-Command -ComputerName $Server -ScriptBlock	{
			$OS = (Get-WMIObject win32_operatingsystem).name

			If ($OS -like "*Windows 11*"){
				Write-Output "$Server"
				Send-MailMessage -From "Moshe's PC <itnotifications@rynj.org>" -To '<mmoskowitz@rynj.org>' -Subject "Windows 11 Found on $Server" -Credential $Credential -UseSSL -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "Please investigate promptly" -WarningAction:SilentlyContinue
			}
															}
	}
	$count += 1
}