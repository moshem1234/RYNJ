$PCs = ConnectionTest -Online -OutArray
Write-Progress -Activity "Finding Webcams"
$Webcams = Invoke-Command -ComputerName $PCs -ScriptBlock {
	Get-PnpDevice -Class Camera,Image -PresentOnly -ErrorAction:SilentlyContinue
}
Write-Progress -Activity "Finding Webcams" -Completed

$Webcams | Select-Object @{name='Room'; expression={Get-RoomNumber -PCName $_.PSComputerName}},PSComputerName,FriendlyName | Sort-Object -Property Room
