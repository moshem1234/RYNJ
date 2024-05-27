@ECHO OFF

:Prompt
set /P Profiles=Would you like to Delete all User Profiles?[Y/N]
if /I NOT "%Profiles%" EQU "Y" if /I NOT "%Profiles%" EQU "N" goto :Prompt
cls

:Uninstall
echo Uninstall
call \\PC1380\Scripts\Uninstall.bat
timeout 100
cls

:MSStore
echo Updating Microsoft Store Apps
powershell \\PC1380\Scripts\MSStoreUpdate.ps1
cls

if /I "%Profiles%" EQU "N" goto :DiskCleanup

:Profiles
echo Deleting Profiles
powershell \\PC1380\Scripts\ClearProfiles.ps1
timeout 100
cls

:DiskCleanup
echo Disk Cleanup
call \\PC1380\Scripts\Disk-Cleanup_Auto.bat
timeout 100
cls

:SFC
echo SFC Scan
call \\PC1380\Scripts\System-Files-Cleanup.bat
timeout 100
cls

:DISM
echo DISM Image Cleanup
call \\PC1380\Scripts\Dism-Image-Cleanup.bat
timeout 100
cls

:Restart
hostname >> \\PC1380\Results\Updated.txt
echo Restarting Computer
powershell Restart-Computer -Force