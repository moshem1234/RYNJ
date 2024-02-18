Param(
	[Switch]$Show
)
$PCs = Get-Content -Path '\\PC1380\Scripts\AllPCs.txt'
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Running Windows Updates" -Status $Server -PercentComplete (($Count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		# Write-Output $Server
		Invoke-Command -ComputerName $Server -ScriptBlock {Update-Module PSWindowsUpdate}
		$Update = Invoke-Command -ComputerName $Server -ScriptBlock {
			Get-WindowsUpdate
		}
		If ($Update) {
			Write-Host "Creating Windows Update Job on $Server" -ForegroundColor Magenta
			Invoke-WUJob -ComputerName $Server -Script {Install-WindowsUpdate -AcceptAll -AutoReboot} -Confirm:$False -RunNow -Force
			If ($Show) {
				$Update
			}
		}
	}
	Else{
	}
	$Count += 1
}
