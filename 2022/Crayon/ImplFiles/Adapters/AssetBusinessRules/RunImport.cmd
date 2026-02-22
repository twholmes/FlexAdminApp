@ECHO OFF
REM This test script will run the Asset Business Rule adapter to automatically retire assets that:
REM - are not linked to inventory 
REM - were previously linked to an inventory device that was in the UQ domain
REM - do not currently have a status of Retired or Disposed
REM 

REM Change to directory containing this file
CD /D %~dp0

"C:\Program Files (x86)\Flexera Software\FlexNet Manager Platform\DotNet\bin\mgsbi.exe" /ConfigFile="AssetBusinessRules.xml" /Import=AssetBusinessRules

REM pause
