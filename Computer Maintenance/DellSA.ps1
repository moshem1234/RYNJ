$PCs = Get-Content -Path '\\PC1380\Scripts\AllPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Mass-Invoking" -Status $Server -PercentComplete (($Count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		$Version = Invoke-Command -ComputerName $Server -ScriptBlock {wmic product where "name = 'Dell SupportAssist'" get version} | Out-String
		If (($Version -NotLike '*3.14.2.45116*') -and ($Version -NotLike '*4.0.0.51819*')) {
			Write-Host $Server -ForegroundColor DarkBlue
			Write-Host $Version
		}
	}
	Else{
	}
	$count += 1
}
