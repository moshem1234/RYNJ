param (
    [switch]$All,
    [switch]$Classrooms,
	[switch]$Offices,
	[switch]$CompLab,
	[switch]$TLounge,
	[string[]]$Array,
	[switch]$Help
)

Function Restart {
	ForEach ($Server in $PCs) {
        
		Write-Progress -Activity "Restarting Computers" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
		
		If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
			Restart-Computer -ComputerName $Server -Force
		}
	
		Else {
			Write-Output "$Server Not Connected"
		}
	
		$count += 1
		
	 }	
}

If ($All){
	$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
	Restart
}
ElseIf ($Classrooms -or $Offices -or $CompLab -or $TLounge -or $Array) {
	If ($Classrooms){
		$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
		Restart
	}
	If ($Offices){
		$PCs = Get-Content -Path \\PC1380\Scripts\OfficePCs.txt
		Restart
	}
	If ($CompLab){
		$PCs = Get-Content -Path \\PC1380\Scripts\CompLabPCs.txt
		Restart
	}
	If ($TLounge){
		$PCs = Get-Content -Path \\PC1380\Scripts\TLoungePCs.txt
		Restart
	}
	If($Array) {
		$PCs = $Array
		Restart
	}
}
Else {
	Write-Output "Please specify parameter from the following (-All -Classrooms -Offices -CompLab -TLounge -Array <string[]>)"
}
