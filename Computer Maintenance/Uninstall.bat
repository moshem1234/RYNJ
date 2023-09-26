@ECHO OFF
wmic product where "Name like 'Java(TM) 6 Update 37'" call uninstall
wmic product where "Name like 'Java(TM) 6 Update 45'" call uninstall
wmic product where "Name like 'Dell Digital Delivery Services'" call uninstall
wmic product where "Name like 'Adobe Flash Player 11 Plugin'" call uninstall
cd "C:\Program Files\Dell\Dell Display Manager 2"
uninst.exe /S
cd "C:\Program Files\Dell\Dell Display Manager 2.0"
uninst.exe /S
powershell -file "\\PC1380\Scripts\OneDrive-Uninstall.ps1"