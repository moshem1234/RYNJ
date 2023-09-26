Wakeup
Start-Sleep -Seconds 60

# $PCs = Get-Content -Path '\\PC1380\Results\Non-UpdatedPCs.txt'
# ForEach ($Server in $PCs) {
# 	Write-Progress -Activity "Updating PCs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
# 	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
# 		Write-Output $Server
# 		Invoke-Command -ComputerName $Server -FilePath '\\PC1380\Scripts\Update-All-In-One.ps1'
# 	}
# 	Else{
# 	}
# 	$count += 1
# }

$PCs = Get-Content -Path '\\PC1380\Results\UpdatedPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Cleaning Up PCs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Write-Output $Server
		Invoke-Command -ComputerName $Server -FilePath '\\PC1380\Scripts\Cleanup-All-In-One.ps1'
	}
	Else{
	}
	$count += 1
}