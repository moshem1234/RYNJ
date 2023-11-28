param (
	[String]$PC
)

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

If ($PC) {
	Write-Host "Waking up $PC" -ForegroundColor Cyan
	$MACAddress = Get-PCMAC -PCName $PC
	WakeOnLanC.exe -w -mac $MACAddress
}
Else {
	Write-Error "No PC Specified"
}