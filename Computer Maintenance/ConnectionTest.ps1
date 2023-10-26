param (
    [switch]$Online,
    [switch]$Offline
)

$CSVData = Import-CSV -Path \\PC1380\Results\Locations.csv
$PCRoomMapping = @{}
ForEach ($Entry in $CSVData) {
    $PCRoomMapping[$Entry."Name"] = $Entry."Room"
}

Function Get-RoomNumber {
    param (
        [string]$PCName
    )
    If ($PCRoomMapping.ContainsKey($PCName)) {
        Return $PCRoomMapping[$PCName]
    }
	Else {
        Return "PC Not Found."
    }
}

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