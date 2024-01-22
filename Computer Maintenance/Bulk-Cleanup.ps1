param (
    [switch]$All,
    [switch]$Classrooms,
	[switch]$Offices,
	[switch]$CompLab,
	[switch]$TLounge,
	[string[]]$Array,
	[switch]$Help
)

Function Cleanup {
	ForEach ($Server in $PCs) {
        
		Write-Progress -Activity "Cleaning Up Computers" -Status $Server -PercentComplete (($Count / $PCs.Count) * 100)
		
		If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
			Write-Host $Server -BackgroundColor DarkMagenta
			Cleanup-Remote -PCName $Server
		}
	
		Else {
			Write-Host "$Server is Offline" -ForegroundColor Red
			Wakeup-PC $Server
			SleepCount (100)
			If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
				Write-Host $Server -BackgroundColor DarkMagenta
				Cleanup-Remote -PCName $Server
			}
		}
	
		$Count += 1
		
	 }	
}

If ($All){
	$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
	Cleanup
}
ElseIf ($Classrooms -or $Offices -or $CompLab -or $TLounge -or $Array) {
	If ($Classrooms){
		$PCs = Get-Content -Path \\PC1380\Scripts\ClassroomPCs.txt
		Cleanup
	}
	If ($Offices){
		$PCs = Get-Content -Path \\PC1380\Scripts\OfficePCs.txt
		Cleanup
	}
	If ($CompLab){
		$PCs = Get-Content -Path \\PC1380\Scripts\CompLabPCs.txt
		Cleanup
	}
	If ($TLounge){
		$PCs = Get-Content -Path \\PC1380\Scripts\TLoungePCs.txt
		Cleanup
	}
	If($Array) {
		$PCs = $Array
		Cleanup
	}
}
Else {
	Write-Output "Please specify parameter from the following (-All -Classrooms -Offices -CompLab -TLounge -Array <string[]>)"
}
