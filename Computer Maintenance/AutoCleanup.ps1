$VolumeCachesRegDir = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
$CacheDirItemNames = Get-ItemProperty "$VolumeCachesRegDir\*" | Select-Object -ExpandProperty PSChildName

$CacheDirItemNames | ForEach-Object{
	$exists = Get-ItemProperty -Path "$VolumeCachesRegDir\$_" -Name "StateFlags7965" -ErrorAction SilentlyContinue
	If (($exists -ne $null) -and ($exists.Length -ne 0)){
			Set-ItemProperty -Path "$VolumeCachesRegDir\$_" -Name StateFlags7965 -Value 2
	}
	Else{
		New-ItemProperty -Path "$VolumeCachesRegDir\$_" -Name StateFlags7965 -Value 0 -PropertyType DWord
	}
}

Start-Process -FilePath cleanmgr.exe -ArgumentList '/sagerun:7965' -Wait