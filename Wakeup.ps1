$CSVData = Import-CSV -Path \\PC1380\Results\Mac-Addresses.csv
$PCMACMapping = @{}
ForEach ($Entry in $CSVData) {
    $PCMACMapping[$entry."PC"] = $Entry."MAC"
}

Function Get-PCMAC {
    param (
        [string]$PCName
    )
    if ($PCMACMapping.ContainsKey($PCName)) {
        return $PCMACMapping[$PCName]
    } else {
        return "PC not found."
    }
}



$PCs = Get-Content -Path '\\PC1380\Scripts\AllPCs.txt'
ForEach ($Server in $PCs) {
	# Write-Progress -Activity "Waking Up PCs" -Status $Server -PercentComplete (($count / $PCs.Count) * 100)
	If (Test-Connection -ComputerName $Server -Quiet -Count 1 -ErrorAction SilentlyContinue) {
	}
	Else{
		Write-Output $Server
		$MACAddress = Get-PCMAC -PCName $Server
		# Write-Output $MACAddress
		WakeOnLanC.exe -w -mac $MACAddress
	}
	$count += 1
}
