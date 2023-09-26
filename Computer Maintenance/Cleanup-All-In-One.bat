@ECHO OFF

echo Uninstall
call \\PC1380\Scripts\Uninstall.bat
timeout 100
cls

echo Updating Microsoft Store Apps
powershell \\PC1380\Scripts\MSStoreUpdate.ps1
cls

echo Deleting Profiles
powershell \\PC1380\Scripts\ClearProfiles.ps1
timeout 100
cls

echo Disk Cleanup
call \\PC1380\Scripts\Disk-Cleanup_Auto.bat
timeout 100
cls

echo SFC Scan
call \\PC1380\Scripts\System-Files-Cleanup.bat
timeout 100
cls

echo DISM Image Cleanup
call \\PC1380\Scripts\Dism-Image-Cleanup.bat
timeout 100
cls

@REM hostname >> \\PC1380\Results\Updated.txt
echo Restarting Computer
powershell Restart-Computer -Force