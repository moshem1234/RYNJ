$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Checking Logs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		$Event3 = Get-WinEvent -ComputerName $Server -LogName "Microsoft-Windows-Kernel-PnP/Configuration" -FilterXPath "*[System[(Level=2)]]" -ErrorAction:SilentlyContinue | Select-Object TimeCreated, Message | Where-Object {($_.TimeCreated -GT $Yesterday) -and ($_.Message -Like "Device USB\VID_0000&PID_0002*")}
		If($Event3){
			Write-Output "Error found on $Server"
			$Errors += "$Server "
		}
	}
	$count += 1
}
If(-not $Errors){
   Write-Output "No Errors"
}