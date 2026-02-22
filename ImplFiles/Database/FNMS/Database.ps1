###########################################################################
# Copyright (C) 2020 Crayon Australia
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

	$tempSetupDir = Join-Path $env:TEMP "Database"
		
	if (!(CopyFiles $dbSetupDir $tempSetupDir)) {
		return $false
	}
	
	if (!(AdjustOpJobsSQL $tempSetupDir)) {
		return $false
	}
	
	$ok = CreateDatabase (GetConfigValue "FNMSInvDBServer") (Join-Path $tempSetupDir "InventoryManagerDatabaseCreation.xml") (GetConfigValue "FNMSInvDBName")
	if (!$ok) {
		return $false
	}
	
	Remove-Item -Recurse -Force $tempSetupDir  | Out-Null

	return $true
}

###########################################################################

function AdjustOpJobsSQL([string]$tempSetupDir)
{
	$file = (Join-Path $tempSetupDir "opjobs.sql")
	
	Log "Adjusting OpJobs: "
	Log "  Removing statements from '$file'."
	Log "  These statements require access to the MSDB database.  However, they are not necessary as they only only remove jobs"
	Log "  that existed in earlier versions of FNMS.   Any such cleanup should only be part of the database migration scripts."
	Log "  See Flexera support case 00890252 for further details"

	$contents = Get-Content $file
	
	$usemsdbline = Select-String $file -Pattern "^USE MSDB$" | Select-Object -First 1

	if ($usemsdbline.linenumber) {
		$contents = $contents | Select-Object -First ($usemsdbline.linenumber - 1)
		$contents | Out-File $file -Encoding ASCII
	}
	
	Log "`tAdjustment of the OpJobs SQL script completed"

	return $true
}