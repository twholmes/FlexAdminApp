@ECHO OFF
REM This test script will run the Enterprise Groups adapter to import data from the businessunit.csv and location.csv files

REM Change to directory containing this file
CD /D %~dp0

"C:\Program Files (x86)\Flexera Software\FlexNet Manager Platform\DotNet\bin\mgsbi.exe" /ConfigFile="AgedInventory.xml" /Import=AgedInventory

REM pause
