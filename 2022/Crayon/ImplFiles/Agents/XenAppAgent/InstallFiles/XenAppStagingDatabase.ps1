###########################################################################
# Copyright (C) 2015 Flexera Software
# 
# This script contains functions that call the installation scripts for 
# creating and configuring a XenApp staging databases.
#
###########################################################################


$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################

function ConfigureXenAppAgentStagingTables
{
	$ad = GetConfigValue "XenAppServerAgentDir"
	$xenAppServerAgentFolder = Join-Path $ScriptPath $ad
	
	if (!(Test-Path $xenAppServerAgentFolder -PathType Container)) {
		Log "" -level "Error"
		Log "ERROR: The XenApp Server Agent folder `"$xenAppServerAgentFolder`" does not exist." -level "Error"

		return $false
	}

	$dbServer = GetConfigValue "XenAppStagingDBServer"
	$dbName = GetConfigValue "XenAppStagingDBName"

	$scripts = Join-Path $xenAppServerAgentFolder "SetupXenAppAgentStagingDatabase.sql"
		
	foreach ($script in $scripts) {
		if  (!(Test-Path $script -PathType Leaf)) {
			Log "" -level "Error"
			Log "ERROR: XenApp Server Agent staging database SQL script does not exist: $script" -level "Error"

			return $false
		}
		
		try {
			Log ""
			Log "Executing SQL script '$script' on database $dbName on $dbServer"
			Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName -InputFile $script -ErrorAction Stop -Verbose
		}
		catch {
			Log "`tError executing SQL script '$script': $_" -level "Error"
			Log "`t$($Error[0].InvocationInfo.PositionMessage)" -level "Error"
			return $false
		}

		Log "`tSQL script successfully executed"
	}
	
	return $true
}
