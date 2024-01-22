$CSVData = Import-CSV -Path C:\Results\IDMapping.csv

$IDEmailMapping = @{}
ForEach ($Entry in $CSVData) {
    $IDEmailMapping[$Entry."DDC-ID"] = $Entry."Email"
}

Function Get-Email {
    param (
        [string]$ID
    )
    If ($IDEmailMapping.ContainsKey($ID)) {
        Return $IDEmailMapping[$ID]
    }
	Else {
        Return "ID Not Found"
    }
}

Set-Location A:\StudentPictures\Renamed
Get-ChildItem -Name | Where-Object {$_ -Like '*(1).jpg'} | Remove-Item -Force
$Files = Get-ChildItem -Name

ForEach ($File in $Files){
	$Total = $Files.Count
	Write-Progress -Activity "Updating Profile Pictures" -Status "$Count/$Total" -PercentComplete (($Count / $Files.Count) * 100)
	$DDCID = $File -Replace "[^\d]"
	$Email = Get-Email $DDCID

	If ($Email -ne "ID Not Found") {
		gam user $Email update photo filename "A:\StudentPictures\Renamed\$File" | Tee-Object -FilePath C:\Results\GamStatus.log -Append
	}
	Else {
		Write-Output "No Email Found - $DDCID" | Tee-Object C:\Results\MissingIDs.log -Append
		# Write-Error "$DDCID - No Email Found"
	}
	$Count ++
}
