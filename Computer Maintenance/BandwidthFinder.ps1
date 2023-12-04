$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
$List = ForEach ($Server in $PCs) {
	Write-Progress -Activity "Finding Speeds" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Invoke-Command -ComputerName $Server -ScriptBlock {Get-NetAdapter -Name Ethernet} | Select-Object @{name='Room'; expression={Get-RoomNumber -PCName $Server}},PSComputerName,LinkSpeed
	}
	Else{
	}
	$count += 1
}

$List | Where-Object LinkSpeed -EQ '100 Mbps' | Sort-Object -Property Room
