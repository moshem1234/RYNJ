param (
	[String]$PCName
)

Invoke-Command -ComputerName $PCName -ScriptBlock {
	Update-Module PSWindowsUpdate
	Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
	Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
	Install-Module PSWindowsUpdate
	Import-Module PSWindowsUpdate
}

$UpdateStatus = Invoke-Command -ComputerName $PCName -ScriptBlock {Get-WindowsUpdate}

If ($UpdateStatus) {
	Write-Host "Windows Updates Found on $Server." -ForegroundColor DarkRed
	Write-Host "Creating Update Job" -ForegroundColor Red
	Invoke-WUJob -ComputerName $Server -Script {Install-WindowsUpdate -AcceptAll -AutoReboot} -Confirm:$False -RunNow -Force
}
Else {
	$PCName >> \\PC1380\Results\Win-UpdatedPCs.txt
	$List = Get-Content -Path \\PC1380\Results\Non-UpdatedPCs.txt | Where-Object {$_ -ne "$PCName"}
	Set-Content -Value $List -Path \\PC1380\Results\Non-UpdatedPCs.txt
}