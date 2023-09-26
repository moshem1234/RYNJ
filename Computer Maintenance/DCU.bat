@ECHO OFF
ECHO Running Update
cd %PROGRAMFILES%\Dell\CommandUpdate
dcu-cli /applyUpdates
timeout 60