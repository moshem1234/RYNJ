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
			Write-Output "$Server Not Connected"
		}
	
		$count += 1
		
	 }	
}

If ($All){
	$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
	ShutDown
}
ElseIf ($Classrooms){
	$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
	ShutDown
}
ElseIf ($Offices){
	$PCs = Get-Content -Path \\PC1380\Scripts\OfficePCs.txt
	ShutDown
}
ElseIf ($CompLab){
	$PCs = Get-Content -Path \\PC1380\Scripts\CompLabPCs.txt
	ShutDown
}
ElseIf ($TLounge){
	$PCs = Get-Content -Path \\PC1380\Scripts\TLoungePCs.txt
	ShutDown
}
ElseIf($Array) {
	$PCs = $Array
	ShutDown
}
Else {
	Write-Output "Please specify parameter from the following (-All -Classrooms -Offices -CompLab -TLounge -Array <string[]>)"
}
