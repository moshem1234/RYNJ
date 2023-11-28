$Users = Get-WmiObject -Class Win32_UserProfile | Where-Object -FilterScript {($_.LocalPath -NotLike 'C:\Windows\*') -and ($_.LocalPath -NotLike '*mmoskowitz*') -and ($_.LocalPath -NotLike '*Moshe')}
ForEach ($User in $Users){
	$User.Delete()
}
Get-ChildItem C:\Users -Name | Where-Object {($_ -NE 'mmoskowitz') -and ($_ -NE 'Moshe') -and ($_ -NE 'Public')} | ForEach-Object {Remove-Item -Path "C:\Users\$_" -Recurse -Force}