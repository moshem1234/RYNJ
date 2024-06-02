param (
	[scriptblock]$Command,
	[switch]$Individual,
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
	$PCs = ConnectionTest -InputPCs $PC_Input -Online -OutArray
	Write-Progress -Activity "Mass Invoking"
	Invoke-Command -ComputerName $PCs -ScriptBlock $Command
	Write-Progress -Activity "Mass Invoking" -Completed
}

Function Invoke-v2 {
	ForEach ($Server in $PC_Input) {
		Write-Progress -Activity "Mass-Invoking" -Status $Server -PercentComplete (($count / $PC_Input.Count) * 100)
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
		$PC_Input = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
		If (-not $Individual) {
			Invoke
		}
		Else {
			Invoke-v2
		}
	}
	ElseIf ($Classrooms -or $Offices -or $CompLab -or $TLounge -or $Array) {
		If ($Classrooms) {
			$PC_Input = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
			If (-not $Individual) {
				Invoke
			}
			Else {
				Invoke-v2
			}
		}
		If ($Offices) {
			$PC_Input = Get-Content -Path \\PC1380\Scripts\OfficePCs.txt
			If (-not $Individual) {
				Invoke
			}
			Else {
				Invoke-v2
			}
		}
		If ($CompLab) {
			$PC_Input = Get-Content -Path \\PC1380\Scripts\CompLabPCs.txt
			If (-not $Individual) {
				Invoke
			}
			Else {
				Invoke-v2
			}
		}
		If ($TLounge) {
			$PC_Input = Get-Content -Path \\PC1380\Scripts\TLoungePCs.txt
			If (-not $Individual) {
				Invoke
			}
			Else {
				Invoke-v2
			}
		}
		If($Array) {
			$PC_Input = $Array
			If (-not $Individual) {
				Invoke
			}
			Else {
				Invoke-v2
			}
		}
	}
	ElseIf ($Help) {
		"SYNTAX: Mass-Invoke [-Command]{ScriptBlock} [-Individual] [-All] [-Classrooms] [-Offices] [-CompLab] [-TLounge] [-Array <string[]>] [-Offline]"
	}
	Else {
		Write-Output "Please specify parameter from the following (-All -Classrooms -Offices -CompLab -TLounge -Array <string[]> -Offline)"
	}
}
Else {
	Write-Output "No command input found. Please try again"
}