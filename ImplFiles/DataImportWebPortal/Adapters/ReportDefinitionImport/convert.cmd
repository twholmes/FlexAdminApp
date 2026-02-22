@ECHO OFF
REM This script runs convert.ps1 to convert a CSV file with Report definitions to an XML format file
REM Created at 03/09/2019 09:00

REM Change to directory containing this file
CD /D %~dp0

REM Run the PowerShell command line as Admin
PowerShell -NoProfile -ExecutionPolicy Bypass "& .\convert.ps1 ReportsViewTest"

pause

