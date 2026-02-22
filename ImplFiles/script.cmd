@ECHO OFF
REM Sample command script used as a default for FlexAdmin
REM Created at 30/10/2019 10:00

REM Change to directory containing this file
CD /D %~dp0

REM 
:Loop
IF "%1"=="" GOTO Continue
ECHO arg1 = %1

IF "%2"=="" GOTO Continue
ECHO arg2 = %2

IF "%3"=="" GOTO Continue
ECHO arg3 = %3

:Continue

REM Run the PowerShell command line as Admin
PowerShell -NoProfile -ExecutionPolicy Bypass "& .\script.ps1 %1 %2 %3"

pause
