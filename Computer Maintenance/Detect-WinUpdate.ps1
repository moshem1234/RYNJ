Param(
	[Switch]$ToRun
)

$PCs = ConnectionTest -Online -OutArray
Write-Progress -Activity "Detecting Windows Updates"

If ($ToRun) {
	Invoke-Command -ComputerName $PCs -ScriptBlock {
		Update-Module PSWindowsUpdate
		$Update = Get-WindowsUpdate | Format-Table
		If ($Update) {
			HOSTNAME
		}
	}
}
Else {
	Invoke-Command -ComputerName $PCs -ScriptBlock {
		Update-Module PSWindowsUpdate
		$Update = Get-WindowsUpdate | Format-Table
		If ($Update) {
			$Update
		}
	}
}

Write-Progress -Activity "Detecting Windows Updates" -Completed