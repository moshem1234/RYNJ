$Date = Get-Date 11/1/2023
$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Checking Logs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Get-WinEvent -ComputerName $Server -LogName "Application" -FilterXPath "*[System[Provider[@Name='Microsoft-Windows-Winlogon'] and (Level=1  or Level=2 or Level=3 or Level=5) and (EventID=6006)]]" -ErrorAction SilentlyContinue | Select-Object @{name='ComputerName'; expression={"$Server"}}, TimeCreated, Message | Where-Object {$_.TimeCreated -GT $Date} | ForEach-Object {If ([Int]($_.Message.Replace("The winlogon notification subscriber ","").Replace(" second(s) to handle the notification event ","").Replace(" took ","").Replace(".","") -Replace "<.*?>" -Replace "\(([^\)]+)\)") -GT 180) {$_}}
	}
		$count += 1
}
