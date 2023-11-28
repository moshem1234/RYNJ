$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Checking Logs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		$Event3 = Get-WinEvent -ComputerName $Server -LogName "Microsoft-Windows-DeviceSetupManager/Admin" -FilterXPath "*[System[Provider[@Name='Microsoft-Windows-DeviceSetupManager' or @Name='Windows Error Reporting'] and (EventID=301 or EventID=112 or EventID=1001)]]" -ErrorAction:SilentlyContinue | Select-Object TimeCreated, Message | Where-Object {($_.TimeCreated -GT $Yesterday) -and (($_.Message -Like "Device 'Unknown USB Device (Configuration Descriptor Request Failed)'*") -or ($_.Message -Like "Device 'Unknown USB Device (Device Descriptor Request Failed)'*"))}
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