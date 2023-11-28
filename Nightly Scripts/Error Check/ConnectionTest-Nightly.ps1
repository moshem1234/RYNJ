Write-Output "" | Out-File \\PC1380\Results\OfflineNightly.txt -Append
Write-Output "=========================" | Out-File \\PC1380\Results\OfflineNightly.txt -Append
Get-Date -Format "MM/dd" | Out-File \\PC1380\Results\OfflineNightly.txt -Append
Write-Output "=========================" | Out-File \\PC1380\Results\OfflineNightly.txt -Append

$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
Foreach ($Server in $PCs) {
    Write-Progress -Activity "Testing Connection" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
    
	$RoomNumber = Get-RoomNumber -PCName $Server

	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
	}
	
	Else {
		Write-Output "$Server (Room $RoomNumber)" | Out-File \\PC1380\Results\OfflineNightly.txt -Append
	}
        
	$count += 1
 }