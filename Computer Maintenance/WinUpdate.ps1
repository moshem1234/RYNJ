Write-Output "Installing Windows Updates"
$OriginalPref = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module PSWindowsUpdate
Import-Module PSWindowsUpdate
Update-Module PSWindowsUpdate
Get-WindowsUpdate -AcceptAll -Install -AutoReboot
$ProgressPreference = $OriginalPref