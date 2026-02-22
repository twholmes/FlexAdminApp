@ECHO OFF
REM Sample command script used to run a PowerShell script
REM Created at 29/10/2020 10:00

REM Change to directory containing this file
CD /D %~dp0

REM Run the PowerShell command line as Admin
PowerShell -NoProfile -ExecutionPolicy Bypass "& .\13-LoadCertificates.ps1"

pause
