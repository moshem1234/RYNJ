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
    if ($PCRoomMapping.ContainsKey($PCName)) {
        return $PCRoomMapping[$PCName]
    } else {
        return "PC not found."
    }
}

$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
Foreach ($Server in $PCs) {
    Write-Progress -Activity "Testing Connection" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
    
	$RoomNumber = Get-RoomNumber -PCName $Server

	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		If ($Online){
			Write-Output "$Server (Room $RoomNumber) Online"
		}
	}
	
	Else {
		If ($Offline){
				Write-Output "$Server (Room $RoomNumber) Offline"
		}
	}
        
	$count += 1
 }