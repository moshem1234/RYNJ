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
ElseIf ($Classrooms){
	$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
	Restart
}
ElseIf ($Offices){
	$PCs = Get-Content -Path \\PC1380\Scripts\OfficePCs.txt
	Restart
}
ElseIf ($CompLab){
	$PCs = Get-Content -Path \\PC1380\Scripts\CompLabPCs.txt
	Restart
}
ElseIf ($TLounge){
	$PCs = Get-Content -Path \\PC1380\Scripts\TLoungePCs.txt
	Restart
}
ElseIf($Array) {
	$PCs = $Array
	ShutDown
}
Else {
	Write-Output "Please specify parameter from the following (-All -Classrooms -Offices -CompLab -TLounge -Array <string[]>)"
}
