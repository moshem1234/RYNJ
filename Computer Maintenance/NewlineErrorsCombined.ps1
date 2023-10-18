param (
    [switch]$All,
    [switch]$Recent
)

$Date = Get-Date 7/1/23
$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt

If ($All) {
	$Count = 0
	$Errors = ForEach ($Server in $PCs) {
		Write-Progress -Activity "Checking Logs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
		If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
			Get-WinEvent -ComputerName $Server -LogName "Microsoft-Windows-Kernel-PnP/Configuration" -FilterXPath "*[System[(Level=2)]]" -ErrorAction:SilentlyContinue | Select-Object @{name='ComputerName'; expression={"$Server"}}, TimeCreated, @{name='Type'; expression={"1: Kernel Error"}}, Message | Where-Object {$_.Message -Like "Device USB\VID_0000&PID_0002*"}
			Get-WinEvent -ComputerName $Server -LogName "Application" -FilterXPath "*[System[Provider[@Name='Windows Error Reporting'] and (Level=4 or Level=0) and (EventID=1001)]]" -ErrorAction:SilentlyContinue | Select-Object @{name='ComputerName'; expression={"$Server"}}, TimeCreated, @{name='Type'; expression={"2: Error Reporting"}}, Message | Where-Object -FilterScript {($_.Message -Like "*USBHUB3*")}
		}
		$Count += 1
	}

	$Errors | Sort-Object -Property TimeCreated -Descending | Select-Object ComputerName, TimeCreated, Type
}

If ($Recent){
	$Count = 0
	$Errors2 = ForEach ($Server in $PCs) {
		Write-Progress -Activity "Checking Logs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
		If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
			Get-WinEvent -ComputerName $Server -LogName "Microsoft-Windows-Kernel-PnP/Configuration" -FilterXPath "*[System[(Level=2)]]" -ErrorAction:SilentlyContinue | Select-Object @{name='ComputerName'; expression={"$Server"}}, TimeCreated, Message | Where-Object {($_.TimeCreated -GT $Date) -and ($_.Message -Like "Device USB\VID_0000&PID_0002*")}
		}
		$Count += 1
	}

	$Errors2 | Sort-Object -Property TimeCreated -Descending | Select-Object ComputerName, TimeCreated
}
