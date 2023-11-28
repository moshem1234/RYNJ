param (
	[Switch]$Auto,
	[Switch]$Profiles,
	[String]$PCName
)
Function SleepCount($S){
	$S0 = $S
Do {
	$M = [Math]::Floor($S / 60)
	$MS = $S % 60
	If ($PSVersionTable.PSVersion.Major -EQ 7) {Write-Progress -SecondsRemaining $s -Activity "Sleeping" -Status "$M Minutes, $MS Seconds Remaining: " -PercentComplete (($S/$S0) * 100) -Id 1}
	Else {Write-Progress -SecondsRemaining $s -Activity "Sleeping" -Status "Time Remaining: " -PercentComplete (($S/$S0) * 100) -Id 1}
	$S--
	Start-Sleep -Seconds 1
}
Until ($S -eq 0)
Write-Progress -Activity "Sleeping" -Completed -Id 1
}

Write-Host "Uninstalling Extra Apps" -ForegroundColor Green
Invoke-Command -ComputerName $PCName -ScriptBlock {
	wmic product where "Name like 'Java(TM) 6 Update 37'" call uninstall
	wmic product where "Name like 'Java(TM) 6 Update 45'" call uninstall
	wmic product where "Name like 'Dell Digital Delivery Services'" call uninstall
	wmic product where "Name like 'Adobe Flash Player 11 Plugin'" call uninstall
}
Invoke-Command -ComputerName $PCName -FilePath \\PC1380\Scripts\OneDrive-Uninstall.ps1
SleepCount (100)

Write-Host "Updating Microsoft Store Apps" -ForegroundColor Green
Invoke-Command -ComputerName $PCName -FilePath \\PC1380\Scripts\MSStoreUpdate.ps1

If ($Profiles) {
	Write-Host "Deleting Profiles" -ForegroundColor Green
	ClearProfiles-Remote -Target $PCName
	SleepCount (100)
}

# Write-Host "Disk Cleanup" -ForegroundColor Green
# Invoke-Command -ComputerName $PCName -ScriptBlock {
# 	$VolumeCachesRegDir = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
# 	$CacheDirItemNames = Get-ItemProperty "$VolumeCachesRegDir\*" | Select-Object -ExpandProperty PSChildName

# 	$CacheDirItemNames | ForEach-Object{
# 		$exists = Get-ItemProperty -Path "$VolumeCachesRegDir\$_" -Name "StateFlags7965" -ErrorAction SilentlyContinue
# 		If (($exists -ne $null) -and ($exists.Length -ne 0)){
# 				Set-ItemProperty -Path "$VolumeCachesRegDir\$_" -Name StateFlags7965 -Value 2
# 		}
# 		Else{
# 			New-ItemProperty -Path "$VolumeCachesRegDir\$_" -Name StateFlags7965 -Value 0 -PropertyType DWord
# 		}
# 	}
# }
# Invoke-Command -ComputerName $PCName -FilePath \\PC1380\Scripts\CleanupTask.ps1
# SleepCount (100)

Write-Host "Creating Cleanup/Scan/Repair Task (SFC,DISM,Restart)" -ForegroundColor Green
Invoke-WUJob -ComputerName $Server -Script {sfc /scannow;Start-Sleep 100;DISM.exe /Online /Cleanup-Image /StartComponentCleanup;DISM.exe /Online /Cleanup-image /Restorehealth;Start-Sleep 100;Restart-Computer -Force} -Confirm:$False -RunNow -Force

# Write-Host "SFC Scan" -ForegroundColor Green
# Invoke-Command -ComputerName $PCName -ScriptBlock {sfc /scannow}
# SleepCount (100)

# Write-Host "DISM Image Cleanup" -ForegroundColor Green
# Invoke-Command -ComputerName $PCName -ScriptBlock {DISM.exe /Online /Cleanup-Image /StartComponentCleanup;DISM.exe /Online /Cleanup-image /Restorehealth}
# SleepCount (100)

# Write-Host "Restarting Computer" -ForegroundColor Green
# Restart-Computer -ComputerName $Target -Force

If ($Auto) {
	$PCName >> \\PC1380\Results\CleanedUpPCs.txt
	$List = Get-Content -Path \\PC1380\Results\Dell-UpdatedPCs.txt | Where-Object {$_ -ne $PCName}
	Set-Content -Value $List -Path \\PC1380\Results\Dell-UpdatedPCs.txt
}