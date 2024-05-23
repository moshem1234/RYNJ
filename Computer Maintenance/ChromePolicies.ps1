If (Test-Path C:\Results\ChromePolicies -ErrorAction SilentlyContinue) {
	Write-Error "C:\Results\ChromePolicies already exists. Exiting..."
	Break
}

mkdir C:\Results\ChromePolicies | Out-Null
Set-Location C:\Results\ChromePolicies

gam print ous fields orgUnitPath | Where-Object {($_ -ne 'orgUnitPath')} | Out-File OUs.txt

gam print chromepolicies ou / show direct > Root.csv

Get-Content OUs.txt | ForEach-Object {$FileName = $_ -replace "[^\w\s]","";$FileName2 = $FileName + ".csv";gam print chromepolicies ou $_ show direct > $Filename2}

Get-ChildItem -Name -Filter *.csv | ForEach-Object {
	If (((Get-Content $_.Trim()) -eq 'name,orgUnitPath,parentOrgUnitPath,direct') -or (-not (Get-Content $_.Trim()))) {
		Remove-Item $_
	}
}

Set-Location C:\Results

$CSVFiles = Get-ChildItem -Path ChromePolicies -Filter *.csv
$Headers = @()
$CombinedData = @()

ForEach ($CSV in $CSVFiles) {
	$Content = Import-CSV -Path $CSV.FullName
	$Headers = $Content[0].PSObject.Properties.Name
	$AllHeaders += $Headers
}
$UniqueHeaders = $AllHeaders | Sort-Object -Unique

ForEach ($CSV in $CSVFiles) {
	$Content = Import-CSV -Path $CSV.FullName
	ForEach ($Row in $Content) {
		$NewRow = New-Object PSObject
		ForEach ($Header in $UniqueHeaders) {
			$NewRow | Add-Member -MemberType NoteProperty -Name $Header -Value ($Row.$Header -as [string])
		}
		$CombinedData += $NewRow
	}
}

$CombinedData | Export-CSV -Path "OUPolicies.csv" -NoTypeInformation