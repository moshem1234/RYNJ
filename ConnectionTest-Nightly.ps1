$CSVData = Import-CSV -Path \\PC1380\Results\Locations.csv
$PCRoomMapping = @{}
ForEach ($Entry in $CSVData) {
    $PCRoomMapping[$entry."Name"] = $Entry."Room"
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