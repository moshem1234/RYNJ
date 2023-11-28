$CSVData = Import-CSV -Path \\PC1380\Results\OfficeUsers.csv
$PCUserMapping = @{}
ForEach ($Entry in $CSVData) {
    $PCUserMapping[$Entry."PCName"] = $Entry."MainUser"
}

Function Get-MainUser {
    Param (
        [string]$PCName
    )
    If ($PCUserMapping.ContainsKey($PCName)) {
        Return $PCUserMapping[$PCName]
    }
	Else {
        Return $NULL
    }
}

$PC = hostname
$MainUser = Get-MainUser $PC

If ($MainUser) {
	$Users = Get-WmiObject -Class Win32_UserProfile | Where-Object -FilterScript {($_.LocalPath -NotLike 'C:\Windows\*') -and ($_.LocalPath -NotLike '*mmoskowitz*') -and ($_.LocalPath -NotLike '*Moshe') -and ($_.LocalPath -NotLike "*$MainUser")}
	ForEach ($User in $Users){
		$User.Delete()
	}
	Get-ChildItem C:\Users -Name | Where-Object {($_ -NE 'mmoskowitz') -and ($_ -NE 'Moshe') -and ($_ -NE 'Public') -and ($_ -NE "$MainUser")} | ForEach-Object {Remove-Item -Path "C:\Users\$_" -Recurse -Force}
}
Else {
	$Users = Get-WmiObject -Class Win32_UserProfile | Where-Object -FilterScript {($_.LocalPath -NotLike 'C:\Windows\*') -and ($_.LocalPath -NotLike '*mmoskowitz*') -and ($_.LocalPath -NotLike '*Moshe')}
	ForEach ($User in $Users){
		$User.Delete()
	}
	Get-ChildItem C:\Users -Name | Where-Object {($_ -NE 'mmoskowitz') -and ($_ -NE 'Moshe') -and ($_ -NE 'Public')} | ForEach-Object {Remove-Item -Path "C:\Users\$_" -Recurse -Force}
}