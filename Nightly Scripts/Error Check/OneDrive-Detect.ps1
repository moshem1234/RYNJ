$PCs = Get-Content -Path '\\PC1380\Scripts\AllPCs.txt'
Write-Host ===========================================================================================
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Detecting OneDrive" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Invoke-Command -ComputerName $Server -ScriptBlock {Get-ScheduledTask | Where-Object 'TaskName' -Like '*onedrive*' | Unregister-ScheduledTask -Confirm:$False}
		$WinGet = Invoke-Command -ComputerName $Server -ScriptBlock {winget list OneDrive --accept-source-agreements}
		If ($WinGet -like "*No installed package found matching input criteria.*"){
			# Write-Host "None Found"
		}
		ElseIf ($NULL -eq $WinGet){
		# 	Write-Host "Winget Needed"
		# 	$NeedWinget += 1
			Write-Host $Server
			Write-Host ===========================================================================================
		}
		Else {
			If ($WinGet -like "*OneDriveSetup.exe*"){
				Write-Host "OneDrive Found; Uninstalling" -ForegroundColor Blue
				Invoke-Command -ComputerName $Server -FilePath "\\PC1380\Scripts\OneDrive-Uninstall.ps1"
				Write-Host "Uninstalled" -ForegroundColor Magenta
				$OneDrive += "$Server "
			}
			Else {
			Write-Host $WinGet -ForegroundColor Blue
			$Errors += "$Server "
			}
			Write-Host $Server
			Write-Host ===========================================================================================
		}
		Invoke-Command -ComputerName $Server -ScriptBlock {
			$Users = Get-ChildItem -Path 'C:\Users'
			$Usernames = $Users.Name
	
			ForEach ($User in $Usernames){
				Remove-Item -Path "C:\Users\$User\OneDrive" -Recurse -Force -ErrorAction:SilentlyContinue
				$AppDataFolders = Get-ChildItem -Path "C:\Users\$User\AppData\Local\Microsoft" -ErrorAction:SilentlyContinue
				If ($AppDataFolders -like "*OneDrive*"){
					Remove-Item -Path "C:\Users\$User\AppData\Local\Microsoft\OneDrive" -Recurse -Force
				}
			}
			Remove-Item 'C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk' -ErrorAction:SilentlyContinue
			Remove-Item C:\Windows\ServiceProfiles\UIFlowService\OneDrive -Recurse -Force -ErrorAction:SilentlyContinue
			Remove-Item C:\Windows\System32\config\systemprofile\AppData\Local\Microsoft\OneDrive -Recurse -Force -ErrorAction:SilentlyContinue
			Remove-Item C:\Windows\System32\config\systemprofile\OneDrive -Recurse -Force -ErrorAction:SilentlyContinue
			Remove-Item C:\WINDOWS\system32\Tasks_Migrated\OneDrive* -Recurse -Force -ErrorAction:SilentlyContinue
			# Remove-Item  -Recurse -Force
		}
	}
	Else{
		# Write-Host $Server
		# Write-Host Offline
		$Offline += "$Server "
	}
	$count += 1
	# Write-Host ===========================================================================================
}
If ($NULL -NE $OneDrive -or $NULL -NE $Errors){
	Send-MailMessage -From 'PC1380 <itnotifications@rynj.org>' -To 'Moshe <mmoskowitz@rynj.org>' -Credential $Credential -UseSSL -Subject 'OneDrive Script Report' -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "The following PCs had OneDrive found and uninstalled: $OneDrive `n`nThe following PCs encountered errors: $Errors" -WarningAction:SilentlyContinue
}