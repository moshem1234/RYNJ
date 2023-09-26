$PCs = Get-Content -Path '\\PC1380\Scripts\AllPCs.txt'
Write-Output ===========================================================================================
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Detecting OneDrive" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Get-ScheduledTask | Where-Object 'TaskName' -Like '*onedrive*' | Unregister-ScheduledTask -Confirm:$False
		$WinGet = Invoke-Command -ComputerName $Server -ScriptBlock {winget list OneDrive --accept-source-agreements}
		If ($WinGet -like "*No installed package found matching input criteria.*"){
			# Write-Output "None Found"
		}
		ElseIf ($NULL -eq $WinGet){
		# 	Write-Output "Winget Needed"
		# 	$NeedWinget += 1
			Write-Output $Server
			Write-Output ===========================================================================================
		}
		Else {
			If ($Winget -like "*Business*"){
				Write-Output "Office 2016 Detected"
				$Office2016 += "$Server "
			}
			ElseIf ($WinGet -like "*OneDriveSetup.exe*"){
				Write-Output "OneDrive Found; Uninstalling"
				Invoke-Command -ComputerName $Server -FilePath "\\PC1380\Scripts\OneDrive-Uninstall.ps1"
				Write-Output "Uninstalled"
				$OneDrive += "$Server "
			}
			Else {
			Write-Output $WinGet
			$Errors += "$Server "
			}
			Write-Output $Server
			Write-Output ===========================================================================================
		}
	}
	Else{
		# Write-Output $Server
		# Write-Output Offline
		$Offline += "$Server "
	}
	$count += 1
	# Write-Output ===========================================================================================
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

	}
}
If($NULL -NE $Office2016 -or $NULL -NE $OneDrive -or $NULL -NE $Errors){
	Send-MailMessage -From 'PC1380 <itnotifications@rynj.org>' -To 'Moshe <mmoskowitz@rynj.org>' -Credential $Credential -UseSSL -Subject 'OneDrive Script Report' -SmtpServer 'smtp-relay.gmail.com' -Port 25 -body "The following PCs still have Office 2016 Installed: $Office2016 `n `nThe following PCs had OneDrive found and uninstalled: $OneDrive `n`nThe following PCs encountered errors: $Errors" -WarningAction:SilentlyContinue
}