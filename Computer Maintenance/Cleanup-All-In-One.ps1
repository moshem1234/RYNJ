Write-Host "Uninstalling Extra Apps" -ForegroundColor Blue
call \\PC1380\Scripts\Uninstall.bat
timeout 100
Clear-Host

Write-Host "Updating Microsoft Store Apps" -ForegroundColor Blue
\\PC1380\Scripts\MSStoreUpdate.ps1
Clear-Host

Write-Host "Deleting Profiles" -ForegroundColor Blue
\\PC1380\Scripts\ClearProfiles.ps1
timeout 100
Clear-Host

Write-Host "Disk Cleanup" -ForegroundColor Blue
\\PC1380\Scripts\AutoCleanup.ps1
timeout 100
Clear-Host

Write-Host "SFC Scan" -ForegroundColor Blue
sfc /scannow
timeout 100
Clear-Host

Write-Host "DISM Image Cleanup" -ForegroundColor Blue
DISM.exe /Online /Cleanup-image /Restorehealth
timeout 100
Clear-Host

hostname >> \\PC1380\Results\CleanedUpPCs.txt
Get-Content -Path \\PC1380\Results\UpdatedPCs.txt | Where-Object {$_ -ne $env:COMPUTERNAME} | Set-Content -Path \\PC1380\Results\UpdatedPCs.txt
Write-Host "Restarting Computer" -ForegroundColor Green
Restart-Computer -Force