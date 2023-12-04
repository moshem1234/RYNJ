Param (
	[String]$PCName
)
$CSVData = Import-CSV -Path \\PC1380\Results\Locations.csv
$PCRoomMapping = @{}
ForEach ($Entry in $CSVData) {
	$PCRoomMapping[$Entry."Name"] = $Entry."Room"
}
If ($PCRoomMapping.ContainsKey($PCName)) {
	Return $PCRoomMapping[$PCName]
}
Else {
    Return "PC Not Found."
}
