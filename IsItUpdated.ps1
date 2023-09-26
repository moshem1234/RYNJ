$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
Get-Content \\PC1380\Results\Updated.txt | Sort-Object | Set-Content \\PC1380\Results\Updated.txt
Set-Content -Path \\PC1380\Results\Online.txt $NULL
Foreach ($Server in $PCs) {
    Write-Progress -Activity "Testing Connection" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
    
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
		Add-Content -Path \\PC1380\Results\Online.txt $Server
	}
	Else {
	}
        
	$count += 1
    
 }

 $PCs2 = Get-Content -Path \\PC1380\Results\Online.txt
 $PCs3 = Get-Content -Path \\PC1380\Results\Updated.txt
 ForEach ($PC in $PCs2){
    Write-Progress -Activity "Cross-checking Online PCs" -Status $PC -PercentComplete (($count2 / $PCs2.Count) * 100)

	$Test = $PCs3 | Select-String -Pattern "$PC"
	# $Test2 = $PCs3 | Select-String -Pattern "NULL"

	If ($NULL -eq $Test){
		Write-Output "$PC has not yet been updated"
	}

	# Else {
	# 	Write-Output "$PC has been updated"
	# }

	$count2 += 1

 }