$PCs = Get-Content -Path '\\PC1380\Scripts\AllPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Detecting Windows Updates" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		# Write-Output $Server
		Invoke-Command -ComputerName $Server -ScriptBlock {
			Update-Module PSWindowsUpdate -Force
			$Update = Get-WindowsUpdate | Format-Table
			If ($Update) {
				HOSTNAME
				query user
				Write-Output $Update
			}
		}
	}
	Else{
	}
	$count += 1
}
