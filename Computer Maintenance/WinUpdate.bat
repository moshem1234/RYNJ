@ECHO OFF
powershell -File \\PC1380\Scripts\WinUpdate.ps1
timeout 10
shutdown /L