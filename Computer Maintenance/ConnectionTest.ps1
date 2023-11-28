param (
    [switch]$Online,
    [switch]$Offline
)

$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
ForEach ($Server in $PCs) {
    Write-Progress -Activity "Testing Connection" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
    
	$RoomNumber = Get-RoomNumber -PCName $Server

	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		If ($Online -or (-not $Online -and -not $Offline)){
			Write-Host "$Server (Room $RoomNumber) Online" -ForegroundColor Green
		}
	}
	
	Else {
		If ($Offline -or (-not $Online -and -not $Offline)){
			Write-Host "$Server (Room $RoomNumber) Offline" -ForegroundColor Red
		}
	}
        
	$count += 1
}