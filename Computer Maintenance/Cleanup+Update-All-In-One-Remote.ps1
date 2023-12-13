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
	}
	$Count += 1
}

Write-Host "Running Dell Updates" -ForegroundColor DarkBlue
$PCs = Get-Content -Path '\\PC1380\Results\Win-UpdatedPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Running Dell Updates" -Status $Server -PercentComplete (($Count2 / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Write-Host $Server -BackgroundColor DarkMagenta
		Dell-Update-Remote -PCName $Server
	}
	Else{
	}
	$Count2 += 1
}

Write-Host "Cleaning Up PCs" -ForegroundColor DarkBlue
$PCs = Get-Content -Path '\\PC1380\Results\Dell-UpdatedPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Cleaning Up PCs" -Status $Server -PercentComplete (($Count3 / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Write-Host $Server -BackgroundColor DarkMagenta
		Cleanup-Remote -PCName $Server -Auto -Profiles
	}
	Else{
	}
	$Count3 += 1
}