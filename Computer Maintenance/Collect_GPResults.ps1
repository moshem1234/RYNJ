$PCs = Get-Content -Path \\PC1380\Scripts\AllPCs.txt
Foreach ($Server in $PCs) {
        
	Write-Progress -Activity "Collecting Results" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
    
	gpresult /SCOPE COMPUTER /H "C:\GPResults\GPResult-$Server.html" /S $Server
  
	$count += 1
    
 }