###########################################################################
# This script contains functions to import IIS logs into the
# FlexNet Manager Suite Compliance database to support subsequent
# monitoring and analysis.
#
# Copyright (C) 2017 Flexera Software
###########################################################################

<#
.SYNOPSIS
flexadmin module to import IIS logs into the dbo.CustomIISLogs table in the FlexNet Manager Suite Compliance database for subsequent monitoring and analysis.

.DESCRIPTION
The Microsoft LogParser.exe utility is used for performing the data load.

When IIS logs are imported into the database, details of which records have been loaded are stored in the file <IIS Log Directory>\FNMSComplianceImportCheckpoint.lpc. On subsequent imports, only new log messages are imported.

If there is a need to re-import a complete set of IIS logs, perform the following steps:

1. Delete all records in the dbo.CustomIISLogs table:
	DELETE FROM dbo.CustomIISLogs
	
2. Delete the <IIS Log Directory>\FNMSComplianceImportCheckpoint.lpc file.

The IISLogQueries.sql file contains a range of sample SQL queries to summarize IIS log details. These queries may be useful as you seek to do your own analysis of HTTP behaviors.

.NOTES
The targets in this module must generally be run with local administrator privileges in order to successfully complete.

The targets in this module can be safely and successfully run on any computer, regardless of whether IIS is or is not installed. If IIS is not installed then no logs will be imported.

.EXAMPLE
.\flexadmin.ps1 ConfigureIISLogImporter

Configure the dbo.CustomIISLogs database table and IIS logging properties. This target must be run before the ImportIISLogs target can be executed successfully.

IIS logging properties are configured to include the following fields in logging in addition to the default fields that IIS logs:
* ComputerName
* BytesSent
* BytesRecv

.EXAMPLE
.\flexadmin.ps1 ImportIISLogs

Import latest IIS logs into the dbo.CustomIISLogs database table, and delete log messages older than a specified number of months (stored in the flexadmin "MonthsToKeepIISLogs" setting).

.EXAMPLE
.\flexadmin.ps1 ConfigureIISLogImportScheduledTask

Configure a scheduled task to execute the ImportIISLogs target to import latest IIS logs into the database each day.
#>

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


############################################################
# Import latest IIS logs into the Compliance database

function ImportIISLogs
{
	Import-Module WebAdministration -ErrorAction SilentlyContinue
	if (!(Get-Module WebAdministration)) {
		Log "WebAdministration PowerShell module not found: not attempt to import IIS logs will be made"
		return $true
	}

	$logParser = Join-Path $ScriptPath "LogParser.exe"

	$db = GetConfigValue "FNMSComplianceDBName"
	$dbServer = GetConfigValue "FNMSDBServer"

	foreach ($ws in (Get-Website))
    {
		$logDir = "$($ws.logFile.directory)\W3SVC$($ws.id)".replace("%SystemDrive%", $env:SystemDrive)

		$checkpointFile = Join-Path $logDir "FNMSComplianceImportCheckpoint.lpc"

		Log "Importing logs for website '$($ws.name)' from $logDir"

		$args = (
			"`"SELECT * INTO dbo.CustomIISLogs FROM '$logDir\*.log'`"",
			"-i:IISW3C",
			"-o:SQL",
			"-server:$dbServer",
			"-database:$db",
			"-iCheckpoint:$checkpointFile"
		)

		$ok = ExecuteProcess $logParser $args
	} 

	return $true
}


############################################################
# Configure fields to be included in IIS logging to ensure good
# quality data is available.
#
# The set of fields configured is the default set used in IIS plus:
# * BytesSent
# * BytesRecv
# * ComputerName

function ConfigureIISLogging
{
	Import-Module WebAdministration -ErrorAction SilentlyContinue
	if (!(Get-Module WebAdministration)) {
		Log "WebAdministration PowerShell module not found: no attempt to import IIS logs will be made"
		return $true
	}

	$flags = "Date,Time,ClientIP,UserName,ComputerName,ServerIP,Method,UriStem,UriQuery,HttpStatus,Win32Status,BytesSent,BytesRecv,TimeTaken,ServerPort,UserAgent,Referer,HttpSubStatus"

	Log "Setting IIS log file flags: $flags"

	Set-WebConfigurationProperty `
		-Filter System.Applicationhost/Sites/SiteDefaults/logfile `
		-Name LogExtFileFlags `
		-Value $flags

	return $true
}
