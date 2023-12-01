param (
	[String]$Target
)

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

$MainUser = Get-MainUser $Target

If ($MainUser) {
	Invoke-Command -ComputerName $Target -ArgumentList $MainUser -ScriptBlock {
		param (
			$MainUser
		)
		$Users = Get-WmiObject -Class Win32_UserProfile | Where-Object -FilterScript {($_.LocalPath -NotLike 'C:\Windows\*') -and ($_.LocalPath -NotLike '*mmoskowitz*') -and ($_.LocalPath -NotLike '*Moshe') -and ($_.LocalPath -NotLike "*$MainUser")}
		ForEach ($User in $Users){
			$UserName = $User.LocalPath.Replace('C:\Users\','')
			Write-Host "Deleting Profile: $UserName" -ForegroundColor Magenta
			$User.Delete()
		}
		Write-Host
		Get-ChildItem C:\Users -Name | Where-Object {($_ -NE 'mmoskowitz') -and ($_ -NE 'mmoskowitz.YNJ') -and ($_ -NE 'Moshe') -and ($_ -NE 'Public') -and ($_ -NE "$MainUser")} | ForEach-Object {Remove-Item -Path "C:\Users\$_" -Recurse -Force}	
	}
}
Else {
	Invoke-Command -ComputerName $Target -ScriptBlock {
		$Users = Get-WmiObject -Class Win32_UserProfile | Where-Object -FilterScript {($_.LocalPath -NotLike 'C:\Windows\*') -and ($_.LocalPath -NotLike '*mmoskowitz*') -and ($_.LocalPath -NotLike '*Moshe')}
		ForEach ($User in $Users){
			$UserName = $User.LocalPath.Replace('C:\Users\','')
			Write-Host "Deleting Profile: $UserName" -ForegroundColor Magenta
			$User.Delete()
		}
		Get-ChildItem C:\Users -Name | Where-Object {($_ -NE 'mmoskowitz') -and ($_ -NE 'mmoskowitz.YNJ') -and ($_ -NE 'Moshe') -and ($_ -NE 'Public')} | ForEach-Object {Remove-Item -Path "C:\Users\$_" -Recurse -Force}
	}
}