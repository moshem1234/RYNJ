$PCs = Get-Content -Path '\\PC1380\Scripts\AllPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Mass-Invoking" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		# Write-Output $Server
		Invoke-Command -ComputerName $Server -ScriptBlock {}
	}
	Else{
	}
	$count += 1
}
