$StartDate =  Get-Date -Date 10/10
$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
ForEach ($Server in $PCs) {
	Write-Progress -Activity "Checking Logs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Get-WinEvent -ComputerName $Server -LogName "Application" -FilterXPath "*[System[Provider[@Name='Microsoft-Windows-Folder Redirection'] and (Level=1  or Level=2 or Level=5)]]" -ErrorAction SilentlyContinue | Where-Object -FilterScript {($_.TimeCreated -GT $StartDate)} | Select-Object @{name='ComputerName'; expression={"$Server"}}, TimeCreated, Message  | Format-Table -AutoSize -Wrap
	}
	$count += 1
}