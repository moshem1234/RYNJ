param (
	[String]$PCName
)

Invoke-Command -ComputerName $PCName -ScriptBlock {
	Set-Location 'C:\Program Files\Dell\CommandUpdate'
	.\dcu-cli /applyUpdates
} | Tee-Object -Variable DellUpdate

If ($DellUpdate -Like "*The program exited with return code: 500*") {
}
ElseIf (($DellUpdate -Like "*The program exited with return code: 1*") -or ($DellUpdate -Like "*The program exited with return code: 5*")) {
	Write-Host "Reboot Required" -ForegroundColor Red
	Restart-Computer -ComputerName $PCName -Force
	Break
}
ElseIf ($DellUpdate -Like "*The program exited with return code: 0*") {
	Break
}
Else {
	Write-Host "Unknown Error Code" -ForegroundColor Red
	Break
}

$PCName >> \\PC1380\Results\Dell-UpdatedPCs.txt
$List = Get-Content -Path \\PC1380\Results\Win-UpdatedPCs.txt | Where-Object {$_ -ne "$PCName"}
Set-Content -Value $List -Path \\PC1380\Results\Win-UpdatedPCs.txt