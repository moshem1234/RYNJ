$PCs = ConnectionTest -Online -OutArray
$Key = Get-Content \\PC1380\Scripts\AES.key
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "itnotifications@rynj.org", (Get-Content \\PC1380\Scripts\ITnotificationsPW.txt | ConvertTo-SecureString -Key $Key)


Write-Progress -Activity "Checking PCs (Windows 11)"
	Invoke-Command -ComputerName $PCs -ScriptBlock	{
		$OS = (Get-WMIObject win32_operatingsystem).name

		If ($OS -like "*Windows 11*"){
			Write-Output "$Server"
			Send-MailMessage -From "Moshe's PC <itnotifications@rynj.org>" -To '<mmoskowitz@rynj.org>' -Subject "Windows 11 Found on $Server" -Credential $Credential -UseSSL -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "Please investigate promptly" -WarningAction:SilentlyContinue
		}
	}
Write-Progress -Activity "Checking PCs (Windows 11)" -Completed