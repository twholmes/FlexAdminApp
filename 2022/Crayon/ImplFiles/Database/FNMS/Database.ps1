###########################################################################
# Copyright (C) 2014-2017 Flexera Software
# 
# Ths contains functions that call the installation scripts for 
# creating and configuring the FNMS databases.
#
###########################################################################


$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################

function CreateDatabase([string]$server, [string]$setupConfig, [string]$databaseName)
{
	$logFile = (Join-Path (GetConfigValue "LogDir") ("DatabaseSetup-$([IO.Path]::GetFileNameWithoutExtension($setupConfig))_{0}.log" -f (Get-Date -format "yyyyMMdd_HHmmss")))

	$args = (
		"-s", $server,
		"-d", $databaseName,
		"-a", "WindowsNT",
		"-i", "`"$setupConfig`"",
		"-l", "`"$logFile`""
	)

	$dir = Split-Path $setupConfig

	$ok = ExecuteProcess (Join-Path $dir "mgsDatabaseCreate.exe") $args

	if (!$ok)
	{
		Log "" -level "Error"
		Log "ERROR: Failed to execute database setup script (review previous output for error details)" -level "Error"

		return $false
	}

	return $true
}

###########################################################################

function UpdateDatabase([string]$server, [string]$setupConfig, [string]$databaseName)
{
	$logFile = (Join-Path (GetConfigValue "LogDir") ("DatabaseSetup-$([IO.Path]::GetFileNameWithoutExtension($setupConfig))_{0}.log" -f (Get-Date -format "yyyyMMdd_HHmmss")))

	$args = (
		"-s", $server,
		"-d", $databaseName,
		"-i", "`"$setupConfig`"",
		"-nsu",
		"-l", "`"$logFile`""
	)

	$dir = Split-Path $setupConfig

	Push-Location $dir

	$ok = ExecuteProcess (Join-Path $dir "mgsDatabaseUpdate.exe") $args

	Pop-Location

	if (!$ok)
	{
		Log "" -level "Error"
		Log "ERROR: Failed to execute database update script (review previous output for error details)" -level "Error"

		return $false
	}

	return $true
}


function DBSetupScriptsSource
{
	if ((GetConfigValue "DoMultiTenantInstall") -eq "Y") {
		$d = "Partitioned"
	} else {
		$d = "Normal"
	}

	return Join-Path (GetConfigValue "FNMSDownloadDir") "Database\$d\FlexNet Manager Platform"
}


###########################################################################

function CreateComplianceDB
{
	$dbSetupDir = DBSetupScriptsSource

	$ok = CreateDatabase (GetConfigValue "FNMSDBServer") (Join-Path $dbSetupDir "ManageSoftDatabaseCreation.xml") (GetConfigValue "FNMSComplianceDBName")
	if (!$ok) {
		return $false
	}

	$ok = CreateDatabase (GetConfigValue "FNMSDBServer") (Join-Path $dbSetupDir "ComplianceDatabaseCreation.xml") (GetConfigValue "FNMSComplianceDBName")
	if (!$ok) {
		return $false
	}

	return $true
}


###########################################################################

function CreateDataWarehouseDB
{
	$dbSetupDir = DBSetupScriptsSource

	$ok = CreateDatabase (GetConfigValue "FNMSDBServer") (Join-Path $dbSetupDir "DataWarehouseCreation.xml") (GetConfigValue "FNMSDataWarehouseDBName")
	if (!$ok) {
		return $false
	}

	return $true
}


###########################################################################

function CreateSnapshotDB
{
	$dbSetupDir = DBSetupScriptsSource

	$ok = CreateDatabase (GetConfigValue "FNMSDBServer") (Join-Path $dbSetupDir "SnapshotDatabaseCreation.xml") (GetConfigValue "FNMSSnapshotDBName")
	if (!$ok) {
		return $false
	}

	return $true
}


###########################################################################

function CreateInventoryDB
{
	$dbSetupDir = DBSetupScriptsSource

	$ok = CreateDatabase (GetConfigValue "FNMSInvDBServer") (Join-Path $dbSetupDir "InventoryManagerDatabaseCreation.xml") (GetConfigValue "FNMSInvDBName")
	if (!$ok) {
		return $false
	}

	return $true
}
