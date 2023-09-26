PowerShell -Command {
	$FileVersion = Get-Content -Path \\PC1380\Results\IntelVersion.txt
	$Test = Get-AppxPackage AppUp.IntelGraphicsExperience
	# Write-Output $Test.Version
	If ($Test.Version -ne "$FileVersion"){
		Send-MailMessage -From "Moshe's PC <itnotifications@rynj.org>" -To '<mmoskowitz@rynj.org>' -Subject "Intel AppxBundle Update Needed" -Credential $Credential -UseSSL -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "https://apps.microsoft.com/store/detail/intel%C2%AE-graphics-command-center/9PLFNLNT3G5G?hl=en-us&gl=us&activetab=pivot%3Aoverviewtab `nhttps://store.rg-adguard.net/"
	}
}