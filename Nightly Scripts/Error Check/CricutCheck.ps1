Set-Location C:\Results\
xidel -s "https://help.cricut.com/hc/en-us/sections/360002412713-Release-Notes" -e=$raw | Out-File ReleaseNotesNew.txt
$Diff = Compare-Object (Get-Content ReleaseNotesOld.txt | Where-Object {$_ -NotLike '<script>(function(){*();</script></body>'}) (Get-Content ReleaseNotesNew.txt | Where-Object {$_ -NotLike '<script>(function(){*();</script></body>'})

If ($Diff) {
	Send-MailMessage -From "Moshe's PC <itnotifications@rynj.org>" -To '<mmoskowitz@rynj.org>' -Subject "New Cricut Version Detected" -Credential $Credential -UseSSL -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "$Diff" -WarningAction:SilentlyContinue
	Move-Item ReleaseNotesNew.txt ReleaseNotesOld.txt -Force
	Write-Host "Files Different: $Diff" -ForegroundColor DarkGreen
}
Else {
	Write-Host "Files Identical" -ForegroundColor DarkGreen
}