$PCs = Get-Content -Path '\\PC1380\Results\AllPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Finding Speeds" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Invoke-Command -ComputerName $Server -ScriptBlock {wmic nic Where netEnabled=true Get Name ',' Speed ',' SystemName}
	}
	Else{
	}
	$count += 1
}
