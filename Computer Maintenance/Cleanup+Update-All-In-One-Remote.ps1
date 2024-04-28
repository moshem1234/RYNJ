Function SleepCount($S){
		$S0 = $S
    Do {
		$M = [Math]::Floor($S / 60)
		$MS = $S % 60
		If ($PSVersionTable.PSVersion.Major -EQ 7) {Write-Progress -SecondsRemaining $s -Activity "Sleeping" -Status "$M Minutes, $MS Seconds Remaining: " -PercentComplete ((($S0-$S)/$S0) * 100) -Id 1}
		Else {Write-Progress -SecondsRemaining $s -Activity "Sleeping" -Status "Time Remaining: " -PercentComplete ((($S0-$S)/$S0) * 100) -Id 1}
        $S--
        Start-Sleep -Seconds 1
    }
	Until ($S -eq 0)
    Write-Progress -Activity "Sleeping" -Completed -Id 1
}

$StartTime = Get-Date

Write-Host "Waking Up Sleeping PCs" -ForegroundColor DarkBlue
Wakeup
SleepCount (120)
Clear-Host

$PCs = Get-Content -Path '\\PC1380\Results\Non-UpdatedPCs.txt'
Write-Host "Restarting PCs" -ForegroundColor DarkBlue
Restart-PCs -Array $PCs
SleepCount (60)

Write-Host "Running Windows Updates" -ForegroundColor DarkBlue
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Running Windows Updates" -Status $Server -PercentComplete (($Count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		# Write-Output $Server
		WindowsUpdate-Remote -PCName $Server
	}
	Else{
		# Write-Host "Waking Up $Server" -ForegroundColor Red
		Wakeup-PC -PC $Server
		SleepCount (60)
		If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
			Write-Host $Server -BackgroundColor DarkMagenta
			WindowsUpdate-Remote -PCName $Server
		}
	}
	$Count += 1
}

$WinUpdatedPCs = $PCs.Count - (Get-Content -Path '\\PC1380\Results\Non-UpdatedPCs.txt').Count

Write-Host "Running Dell Updates" -ForegroundColor DarkBlue
$PCs = Get-Content -Path '\\PC1380\Results\Win-UpdatedPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Running Dell Updates" -Status $Server -PercentComplete (($Count2 / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Write-Host $Server -BackgroundColor DarkMagenta
		Dell-Update-Remote -PCName $Server
	}
	Else{
		# Write-Host "Waking Up $Server" -ForegroundColor Red
		Wakeup-PC -PC $Server
		SleepCount (60)
		If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
			Write-Host $Server -BackgroundColor DarkMagenta
			Dell-Update-Remote -PCName $Server
		}
	}
	$Count2 += 1
}

$DellUpdatedPCs = $PCs.Count - (Get-Content -Path '\\PC1380\Results\Win-UpdatedPCs.txt').Count

Write-Host "Cleaning Up PCs" -ForegroundColor DarkBlue
$PCs = Get-Content -Path '\\PC1380\Results\Dell-UpdatedPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Cleaning Up PCs" -Status $Server -PercentComplete (($Count3 / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Write-Host $Server -BackgroundColor DarkMagenta
		Cleanup-Remote -PCName $Server -Auto -Profiles
	}
	Else{
		# Write-Host "Waking Up $Server" -ForegroundColor Red
		Wakeup-PC -PC $Server
		SleepCount (60)
		If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
			Write-Host $Server -BackgroundColor DarkMagenta
			Cleanup-Remote -PCName $Server -Auto -Profiles
		}
	}
	$Count3 += 1
}

SleepCount (3600)

Write-Host "Waking Up Sleeping PCs" -ForegroundColor DarkBlue
Wakeup
SleepCount (120)

$PCs = Get-Content -Path '\\PC1380\Results\CleanedUpPCs.txt'
Write-Host "Restarting PCs" -ForegroundColor DarkBlue
Restart-PCs -Array $PCs

$CleanedUpPCs = $PCs.Count - (Get-Content -Path '\\PC1380\Results\CleanedUpPCs.txt').Count

$TimeTaken = (Get-Date) - $StartTime
$TotalHours = $TimeTaken.TotalHours
$HoursTaken = $TimeTaken.Hours
$MinutesTaken = $TimeTaken.Minutes

Send-MailMessage -From "Moshe's PC <itnotifications@rynj.org>" -To '<mmoskowitz@rynj.org>' -Subject "Mass Cleanup Completed in $HoursTaken Hours, $MinutesTaken Minutes" -Credential $Credential -UseSSL -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "$WinUpdatedPCs Windows Updates Completed`n`n$DellUpdatedPCs Dell Updates Completed`n`n$CleanedUpPCs PCs Cleaned Up`n`nScript Execution Completed in $TotalHours Hours" -WarningAction:SilentlyContinue