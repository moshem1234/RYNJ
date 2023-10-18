$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Checking Logs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		$Event3 = Get-WinEvent -ComputerName $Server -LogName "Application" -FilterXPath "*[System[Provider[@Name='Windows Error Reporting'] and (Level=4 or Level=0) and (EventID=1001)]]" -ErrorAction:SilentlyContinue | Select-Object @{name='ComputerName'; expression={"$Server"}}, TimeCreated, Message | Where-Object -FilterScript {($_.TimeCreated -GT $Yesterday) -and ($_.Message -Like "*USBHUB3*")}
		If($NULL -NE $Event3){
			Write-Output "Error found on $Server"
			$Errors += "$Server "
		}
	}
	$count += 1
}
If($NULL -EQ $Errors){
   Write-Output "No Errors"
}