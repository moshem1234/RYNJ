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

Function Get-Webcams {
	$PCs = Get-Content -Path '\\PC1380\Scripts\AllPCs.txt'
	# Write-Output "Room,Webcam"
	ForEach ($Server in $PCs) {
		Write-Progress -Activity "Mass-Invoking" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
		If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
			$Room = Get-RoomNumber -PCName $Server
			$Status = Invoke-Command -ComputerName $Server -ScriptBlock {Get-PnpDevice -Class Camera,Image -PresentOnly -ErrorAction:SilentlyContinue | Select-Object FriendlyName}
			If ($NULL -ne $Status){
				$Webcam = $Status.FriendlyName
				Write-Output "$Room,$Webcam"
			}
		}
		Else{
		}
		$count += 1
	}
}

Get-Webcams | Out-File C:\Windows\Temp\Webcams.csv
Import-CSV -Path C:\Windows\Temp\Webcams.csv -Header Room,Webcam | Sort-Object -Property Room | Write-Output