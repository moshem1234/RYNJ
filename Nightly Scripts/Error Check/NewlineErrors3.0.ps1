$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Finding Newline Errors (3)" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		$Event4 = Get-WinEvent -ComputerName $Server -LogName "Microsoft-Windows-DeviceSetupManager/Admin" -FilterXPath "*[System[Provider[@Name='Microsoft-Windows-DeviceSetupManager' or @Name='Windows Error Reporting'] and (EventID=301 or EventID=112 or EventID=1001)]]" -ErrorAction:SilentlyContinue | Select-Object TimeCreated, Message | Where-Object {($_.TimeCreated -GT $Yesterday) -and (($_.Message -Like "Device 'Unknown USB Device (Configuration Descriptor Request Failed)'*") -or ($_.Message -Like "Device 'Unknown USB Device (Device Descriptor Request Failed)'*"))}
		If($Event4){
			Restart-Computer -ComputerName $Server -Force
			$Errors += "$Server "
		}
	}
	$count += 1
}
If($Errors){
	$Date = Get-Date -Format m
	Write-Output "$Date - $Errors " | Out-File C:\Results\NewlineErrors3.txt -Append 
}