Param (
	[string[]]$InputPCs,
    [switch]$Online,
    [switch]$Offline,
	[switch]$OutArray
)

If ($InputPCs) {
	$PCs = $InputPCs
}
Else {
	$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
}

ForEach ($Server in $PCs) {
    Write-Progress -Activity "Testing Connection" -Status $Server -PercentComplete (($Count / $PCs.Count) * 100)
    
	$RoomNumber = Get-RoomNumber -PCName $Server

	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		If ($Online -or (-not $Online -and -not $Offline)){
			If (-not $OutArray) {
				Write-Host "$Server (Room $RoomNumber) Online" -ForegroundColor Green
			}
			Else {
				$Server
			}
		}
	}
	
	Else {
		If ($Offline -or (-not $Online -and -not $Offline)){
			If (-not $OutArray) {
				Write-Host "$Server (Room $RoomNumber) Offline" -ForegroundColor Red
			}
			Else {
				$Server
			}
		}
	}
        
	$Count += 1
}
Write-Progress -Activity "Testing Connection" -Completed
