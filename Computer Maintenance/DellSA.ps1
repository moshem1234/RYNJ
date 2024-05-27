$PCs = Get-Content -Path '\\PC1380\Scripts\AllPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Mass-Invoking" -Status $Server -PercentComplete (($Count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		$Version = Invoke-Command -ComputerName $Server -ScriptBlock {wmic product where "name = 'Dell SupportAssist'" get version} | Out-String
		If ($Version) {
			Write-Host $Server -ForegroundColor DarkBlue
			Write-Host $Version
		}
	}
	Else{
	}
	$count += 1
}
