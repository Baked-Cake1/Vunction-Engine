@echo off
setlocal

:: Set the name of the PowerShell script to find
set "scriptName=Vunction Engine Antivirus.ps1"

:: Get the directory where the batch script is located
set "scriptDir=%~dp0"

:: Search for the PowerShell script in the directory
if exist "%scriptDir%%scriptName%" (
    echo Found %scriptName% in %scriptDir%
    echo Running %scriptName% with PowerShell ISE...
    "C:\Windows\system32\WindowsPowerShell\v1.0\powershell_ise.exe" -File "%scriptDir%%scriptName%"
) else (
    echo %scriptName% not found in %scriptDir%
)

endlocal
pause