param (
	[string]$Command,
    [switch]$All,
    [switch]$Classrooms,
	[switch]$Offices,
	[switch]$CompLab,
	[switch]$TLounge,
	[string[]]$Array,
	[switch]$Offline,
	[switch]$Help
)

Function Invoke {
	ForEach ($Server in $PCs) {
		Write-Progress -Activity "Mass-Invoking" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
		If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
			$ScriptBlock = [scriptblock]::Create($Command)
			Invoke-Command -ComputerName $Server -ScriptBlock $ScriptBlock
		}
		Else {
			If ($Offline) {
				Write-Host "$Server is Offline" -ForegroundColor Red
			}
		}
		$count += 1
	}
}

If ($Command) {
	If ($All) {
		$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
		Invoke
	}
	ElseIf ($Classrooms -or $Offices -or $CompLab -or $TLounge -or $Array) {
		If ($Classrooms) {
			$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
			Invoke
		}
		If ($Offices) {
			$PCs = Get-Content -Path \\PC1380\Scripts\OfficePCs.txt
			Invoke
		}
		If ($CompLab) {
			$PCs = Get-Content -Path \\PC1380\Scripts\CompLabPCs.txt
			Invoke
		}
		If ($TLounge) {
			$PCs = Get-Content -Path \\PC1380\Scripts\TLoungePCs.txt
			Invoke
		}
		If($Array) {
			$PCs = $Array
			Invoke
		}
	}
	Else {
		Write-Output "Please specify parameter from the following (-All -Classrooms -Offices -CompLab -TLounge -Array <string[]> -Offline)"
	}
}
Else {
	Write-Output "No command input found. Please try again"
}