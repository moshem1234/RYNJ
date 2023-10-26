param (
    [switch]$All,
    [switch]$Classrooms,
	[switch]$Offices,
	[switch]$CompLab,
	[switch]$TLounge,
	[string[]]$Array,
	[switch]$Help
)

Function ShutDown {
	ForEach ($Server in $PCs) {
        
		Write-Progress -Activity "Shutting Down Computers" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
		
		If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
			Stop-Computer -ComputerName $Server -Force
		}
	
		Else {
			Write-Host "$Server is Offline" -ForegroundColor Red
		}
	
		$count += 1
		
	 }	
}

If ($All){
	$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
	ShutDown
}
ElseIf ($Classrooms -or $Offices -or $CompLab -or $TLounge -or $Array) {
	If ($Classrooms){
		$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
		ShutDown
	}
	If ($Offices){
		$PCs = Get-Content -Path \\PC1380\Scripts\OfficePCs.txt
		ShutDown
	}
	If ($CompLab){
		$PCs = Get-Content -Path \\PC1380\Scripts\CompLabPCs.txt
		ShutDown
	}
	If ($TLounge){
		$PCs = Get-Content -Path \\PC1380\Scripts\TLoungePCs.txt
		ShutDown
	}
	If($Array) {
		$PCs = $Array
		ShutDown
	}
}
Else {
	Write-Output "Please specify parameter from the following (-All -Classrooms -Offices -CompLab -TLounge -Array <string[]>)"
}
