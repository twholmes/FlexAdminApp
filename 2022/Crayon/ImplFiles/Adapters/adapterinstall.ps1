###########################################################################
# Copyright (C) 2017 Flexera Software
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
#

function InstallAdapters
{
  $FNMSServiceAccount = GetConfigValue "FNMSServiceAccount"
  $cred = GetCredentials `
      "Requesting password for the FNMS service account to configure Task User Identity..." `
      "Scheduled Task credentials" `
      "Enter user credentials for running the scheduled task" `
      $FNMSServiceAccount

  if (!$cred) 
  { # Cancelled?
    Log "Configuration cancelled by user"
    return $false
  }
  
  $ok = InstallAssetBusinessRulesAdapter $cred.UserName $cred.GetNetworkCredential().Password 
  $ok = InstallEnterpriseGroupsAdapter $cred.UserName $cred.GetNetworkCredential().Password 
  $ok = InstallUnifyPOAdapter $cred.UserName $cred.GetNetworkCredential().Password   
  $ok = InstallHRUsersAdapter $cred.UserName $cred.GetNetworkCredential().Password
  $ok = InstallAgedInventoryAdapter $cred.UserName $cred.GetNetworkCredential().Password       

	Log "`tAll adapters installed"

	return $true
}

###########################################################################
#

function InstallAssetBusinessRulesAdapter([string]$user, [string]$password)
{
  $taskname = "FlexNet Manager Platform\Apply Asset Business Rules"
  $schedulingOptions = ("/sc", "DAILY", "/st", "06:15:00")
 
  $ok = InstallAdapter $taskName "AssetBusinessRules" $schedulingOptions $user $password 
  if (!$ok) 
  {
    Log "ERROR: Error creating adapter" -level "Error"
    return $false
  }
	Log "`tAssetBusinessRules business adapter installed"
  Log ""
	return $true
}


###########################################################################
#

function InstallEnterpriseGroupsAdapter([string]$user, [string]$password)
{
  $taskname = "FlexNet Manager Platform\Import EnterpriseGroups data"
  $schedulingOptions = ("/sc", "DAILY", "/st", "06:00:00")
 
  $ok = InstallAdapter $taskName "EnterpriseGroups" $schedulingOptions $user $password 
  if (!$ok) 
  {
    Log "ERROR: Error creating adapter" -level "Error"
    return $false
  }
	Log "`tEnterpriseGroups business adapter installed"
  Log ""
	return $true
}

###########################################################################
#

function InstallUnifyPOAdapter([string]$user, [string]$password)
{
  $taskname = "FlexNet Manager Platform\Import UnifyPO data"
  $schedulingOptions = ("/sc", "DAILY", "/st", "07:00:00")
 
  $ok = InstallAdapter $taskName "UnifyPO" $schedulingOptions $user $password 
  if (!$ok) 
  {
    Log "ERROR: Error creating adapter" -level "Error"
    return $false
  }
	Log "`tUnifyPO business adapter installed"
  Log ""
	return $true
}

###########################################################################
#

function InstallHRUsersAdapter([string]$user, [string]$password)
{
  $taskname = "FlexNet Manager Platform\Import HRUsers data"
  $schedulingOptions = ("/sc", "DAILY", "/st", "05:00:00")
 
  $ok = InstallAdapter $taskName "HRUsers" $schedulingOptions $user $password 
  if (!$ok) 
  {
    Log "ERROR: Error creating adapter" -level "Error"
    return $false
  }
	Log "`tHRUsers business adapter installed"
  Log ""
	return $true
}

###########################################################################
#

function InstallAgedInventoryAdapter([string]$user, [string]$password)
{
  $taskname = "FlexNet Manager Platform\Import Aged Inventory data"
  $schedulingOptions = ("/sc", "DAILY", "/st", "05:00:00")
 
  $ok = InstallAdapter $taskName "AgedInventory" $schedulingOptions $user $password 
  if (!$ok) 
  {
    Log "ERROR: Error creating adapter" -level "Error"
    return $false
  }
	Log "`tAgedInventory business adapter installed"
  Log ""
	return $true
}

###########################################################################
#

function InstallAdapter([string]$taskName, [string]$folder, [string[]]$schedulingOptions, [string]$user, [string]$password)
{
  $adaptersDir = GetConfigValue "FNMSBusinessAdaptersDir"

	# Get the adapter install folder
	$sourceDir = Join-Path $ScriptPath $folder
	$targetDir = Join-Path $adaptersDir $folder

	Log "Removing existing installed business adapters"
	if (Test-Path -Path $targetDir) {
		Remove-Item -Recurse -Force $targetDir
	}

	Log "Installing $folder business adapters to '$targetDir'"
	if (!(CopyFiles $sourceDir $targetDir)) {
		return $false
	}

  # Find the installed copy of MGSBI
	$id = GetFNMSInstallDir
	if (!$id) {
		Log "" -level "Error"
		Log "ERROR: Could not determine FlexNet Manager Suite installation directory from HKLM\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\ComplianceInstallDir registry entry" -level "Error"

		return $false
	}
  $mgsbi = Join-Path $id "DotNet\bin\mgsbi.exe"
  Log "MGSBI installed at: $mgsbi"  

  Log "Creating scheduled task for $folder"
  $ok = CreateScheduledTask $taskName "`"$targetDir\RunImport.cmd`"" $schedulingOptions $user $password 
  if (!$ok) 
  {
    Log "ERROR: Error creating scheduled task" -level "Error"
  }

	return $true
}

###########################################################################
#
function CreateScheduledTask([string]$taskName, [string]$commandLine, [string[]]$schedulingOptions, [string]$user, [string]$password)
{
	$args = 
	(
		"/create",
		"/tn", "`"$taskName`"",
		"/tr", ("`"{0}`"" -f ($commandLine -replace '"', '\"')),
		"/f",
		"/ru", $user
	)
	
	if ($password) 
	{
		$args += ("/rp", $password)
	}
	$args += $schedulingOptions

	$ok = ExecuteProcess "schtasks.exe" $args -hiddenArguments ($password)
	if (!$ok) 
	{
		Log "" -level "Error"
		Log "ERROR: Failed to create scheduled task '$taskName'" -level "Error"
		return $false
	}

	return $true
}


###########################################################################
#

function ConfigureExcelDriversForSpreadsheetImports
{
	Log "Configuring drivers for Excel 2013 spreadsheets"
	$key = "HKLM:\SOFTWARE\Microsoft\Office\15.0\Access Connectivity Engine\Engines\Excel"
	if ((Configure-ExcelDrivers $key) -eq $false)
	{
  	Log "Configuring drivers for Excel 2010 spreadsheets"
  	$key = "HKLM:\SOFTWARE\Microsoft\Office\14.0\Access Connectivity Engine\Engines\Excel"
  	if ((Configure-ExcelDrivers $key) -eq $false)
  	{
  		Log "" -level "Error"
  		Log "ERROR: Could not configure drivers for Excel 2010 spreadsheets by configuring values under $key" -level "Error"
	  	Log "Check that the 'Microsoft Access Database Engine 2010 Redistributable (32 bit)' components are installed" -level "Error"
	  	Log "These can be downloaded from: https://www.microsoft.com/en-us/download/details.aspx?id=13255" -level "Error"

	  	return $false
	  }
	  Log "`tDrivers for Excel 2010 spreadsheets configured"

	  Log "Configuring drivers for Excel 2003 spreadsheets"
	  $key = "HKLM:\SOFTWARE\Microsoft\Jet\4.0\Engines\Excel"
	  if ((Configure-ExcelDrivers $key) -eq $false)
	  {
  		Log "" -level "Error"
	  	Log "ERROR: Could not configure drivers for Excel 2003 spreadsheets by configuring values under $key" -level "Error"

		  return $false
	  }
	  Log "`tDrivers for Excel 2003 spreadsheets configured"
	  return $true
	}
	Log "`tDrivers for Excel 2013 spreadsheets configured"	
	
	return $true
}


###########################################################################
# This function configures Microsoft Excel drivers with settings
# to reliably read data from Excel spreadsheets while running business adapters.

function Configure-ExcelDrivers([string]$key)
{
	$wow64key = $key -replace "HKLM:\\SOFTWARE\\", "HKLM:\SOFTWARE\Wow6432Node\"

	if ((Test-Path $wow64key))
	{
		$key = $wow64key
	}
	elseif (!(Test-Path $key))
	{
		return $false
	}

	# Do not scan any rows of data to guess column data types
	Set-ItemProperty -path $key -name "TypeGuessRows" -Value 0 -Type "DWORD"

	# Import all columns as text
	Set-ItemProperty -path $key -name "ImportMixedTypes" -Value "Text"
}


