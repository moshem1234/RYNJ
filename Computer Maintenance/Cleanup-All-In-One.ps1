Write-Output "Uninstalling Extra Apps"
call \\PC1380\Scripts\Uninstall.bat
timeout 100
Clear-Host

Write-Output "Updating Microsoft Store Apps"
\\PC1380\Scripts\MSStoreUpdate.ps1
Clear-Host

Write-Output "Deleting Profiles"
\\PC1380\Scripts\ClearProfiles.ps1
timeout 100
Clear-Host

Write-Output "Disk Cleanup"
\\PC1380\Scripts\AutoCleanup.ps1
timeout 100
Clear-Host

Write-Output "SFC Scan"
sfc /scannow
timeout 100
Clear-Host

Write-Output "DISM Image Cleanup"
DISM.exe /Online /Cleanup-image /Restorehealth
timeout 100
Clear-Host

hostname >> \\PC1380\Results\CleanedUpPCs.txt
Get-Content -Path \\PC1380\Results\UpdatedPCs.txt | Where-Object {$_ -ne $env:COMPUTERNAME} | Set-Content -Path \\PC1380\Results\UpdatedPCs.txt
Write-Output "Restarting Computer"
Restart-Computer -Force