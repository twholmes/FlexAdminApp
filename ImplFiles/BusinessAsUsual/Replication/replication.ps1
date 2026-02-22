###########################################################################
# Copyright (C) 2020 Craton Auastralia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Configure the web.config file for Replication

function ConfigureWebConfigForReplication([string]$installDir, [string]$useReplication, [string]$replicationLocation)
{
	$webConfig = Join-Path $installDir "Importers\web.config"
	Log "Checking UseReplication in $webConfig"

	$c = [xml](Get-Content $webConfig)

  # update the UseReplication setting
	$i = Select-Xml -Xml $c -XPath "/configuration/appSettings/add[@key='UseReplication']"
	if (!$i) {
		Log "ERROR: /configuration/appSettings/add key=UseReplication element not found in $webConfig" -level Error
		return $false
	}
	Log "`tCurrent UseReplication value: $($i.Node.value)"
	$i.Node.SetAttribute("value", $useReplication)
	Log "`tNew UseReplication value: $($i.Node.value)"	
	Write-Host ""
	
  # update the UseReplication setting
	$i = Select-Xml -Xml $c -XPath "/configuration/appSettings/add[@key='ReplicationLocation']"
	if (!$i) {
		Log "ERROR: /configuration/appSettings/add key=ReplicationLocation element not found in $webConfig" -level Error
		return $false
	}
	Log "`tCurrent ReplicationLocation value: $($i.Node.value)"
	$i.Node.SetAttribute("value", $replicationLocation)
	Log "`tNew ReplicationLocation value: $($i.Node.value)"	
		
  # save web.config
	$c.Save($webConfig)  
		
	return $true
}

###########################################################################
# Configure web.config file to turn Replication ON

function ConfigureReplicationON
{
	$id = GetFNMSInstallDir
	if (!$id) {
	  Write-Host ""
		Log "ERROR: Could not determine FlexNet Manager Suite installation directory from HKLM\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\ComplianceInstallDir registry entry" -level Error
		return $false
	}

  $replicationdir = GetConfigValue "ReplicationDirectory"

  $ok = ConfigureWebConfigForReplication $id "true" $replicationdir
	if ($ok) {
	  Write-Host ""	
    Log "Starting IIS ..." -Level Warning
    IISReset /start | Out-Null
	  Write-Host ""
	  return $true
	}
	return $ok
}

###########################################################################
# Configure web.config file to turn Replication OFF

function ConfigureReplicationOFF
{
	$id = GetFNMSInstallDir
	if (!$id) {
	  Write-Host ""
		Log "ERROR: Could not determine FlexNet Manager Suite installation directory from HKLM\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\ComplianceInstallDir registry entry" -level Error
		return $false
	}

  $replicationdir = GetConfigValue "ReplicationDirectory"

  $ok = ConfigureWebConfigForReplication $id "false" $replicationdir
	if ($ok) {
	  Write-Host ""	
    Log "Starting IIS ..." -Level Warning
    IISReset /start | Out-Null
	  Write-Host ""
	  return $true
	}
	return $ok
}


############################################################
# Helper function 

function DoMoveFiles([string]$sourcepath, [string]$incoming, [string]$filter)
{
	Log ""
	Log "Moving replicated files from $sourcepath to $incoming"
	Log "Filter: $filter"
	
	if (-not (Test-Path -LiteralPath $sourcepath)) {
		Log "Source path does not exist: $sourcepath" -level Warning
		return
	}
	
	if (-not (Test-Path -LiteralPath $incoming)) {
		Log "Incoming path does not exist: $incoming" -level Warning
		return
	}

	$moved = 0;
	$failures = 0;

	Log "Moving files:"

	Get-ChildItem -LiteralPath $sourcepath |
	?{ $file = $_; -not $_.PSIsContainer -and $file.FullName -like $filter } | 
	%{
		$file = $_
		$fileName = $file.FullName;
		try {
			Log "`t$fileName"
			Copy-Item -LiteralPath $fileName -Destination $incoming -ErrorAction Stop
			++$moved;
		} catch {
			++$failures;
			Log "Failed to move $($fileName): $($_)" -level Warning
		}

		Write-Progress -Activity "Moving replicated files" -Status "$moved file(s) moved, $failures file(s) skipped"
	};
	Write-Progress -Activity "Moving replicated files" -Status "Complete" -Completed

	Log ""
	Log "Completed: $moved item(s) moved, $failures file(s) skipped"
}


###########################################################################
# Moves files from the replication director to Incomming

function MoveFilesFromReplication
{
  $replicationdir = GetConfigValue "ReplicationDirectory"
  $repInventories = Join-Path $replicationdir "inventories"

	$inc = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\Reporter\CurrentVersion\IncomingDirectory" -name Tracker -ErrorAction Ignore).Tracker
	if ($inc) {
    DoMoveFiles $repInventories $inc -filter "*.*"			
	}
	return $true
}

