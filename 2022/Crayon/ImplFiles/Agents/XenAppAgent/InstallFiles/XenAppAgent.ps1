###########################################################################
# Copyright (C) 2015 Flexera Software
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


######################################################################

function GetConnectionParameters
{
	$dbServer = GetConfigValue "XenAppStagingDBServer"
	$dbName = GetConfigValue "XenAppStagingDBName"

	$connectionParameters = ( "Data Source=$dbServer", "Database=$dbName")

	$user = GetConfigValue "XenAppStagingDBSQLAccount"
	if ($user) {
		$connectionParameters += "User Id=$user"
		$pwdParam = "Password=$(GetConfigValue "XenAppStagingDBSQLAccountPassword")"
		
		$connectionParameters += $pwdParam
	} else {
		$connectionParameters += "Integrated Security=true"	
	}
	
	return $connectionParameters
}


###########################################################################
# This function explicitly gets the config parameters so that the 
# installing user will be prompted to enter their values if they haven't
# already been configured in the fnmssettings.config file.  The parameters
# will then be automatically saved to the fnmssettings.config file, ready
# for when the XenApp server agent scheduled task is run.
#

function RequestXenAppAgentParameters
{
	$ad = GetConfigValue "XenAppServerAgentDir"
	
	$connectionParameters = GetConnectionParameters

	# Validate password for SQL account
	if ((GetConfigValue "XenAppStagingDBSQLAccount") -and !(Test-SQLConnection $connectionParameters)) {
		Log "Unable to connect to the beacon database. If the parameters specified are incorrect, edit them in the fnmssettings.config file and rerun this step." -level Error
		return $false
	}

	return $true
}


######################################################################

function RunAgent
{
	$ld = GetConfigValue "LogDir"
	$ad = GetConfigValue "XenAppServerAgentDir"
	
	$connectionParameters = GetConnectionParameters

	$connectionString = $connectionParameters -join ";"
	
	$cmd = Join-Path (Join-Path $ScriptPath $ad) "FnmpXenAppAgent.exe"

	# Run with the log directory as the working directory so that the log file will be written there.
	Push-Location $ld
	
	$params = (
		"-d", "`"$connectionString`"",
		"-v", "9"
	)

	if (GetConfigValue "XenAppStagingDBSQLAccount") {
		# If using SQL auth, the password is in the connection string - hide the detail from logging
		$hiddenArguments = "`"$connectionString`""
	} else {
		$hiddenArguments = $null
	}

	$result = ExecuteProcess -exe $cmd -arguments $params -hiddenArguments $hiddenArguments

	$logFile = "FnmpXenAppAgent.log" # XenApp agent uses a hard-coded log file name
	if (Test-Path $logFile -pathType leaf) {
		Move-Item $logFile (Join-Path (GetConfigValue "LogDir") ("FnmpXenAppAgent_{0}.log" -f (Get-Date -format "yyyyMMdd_HHmmss")))
	}

	Pop-Location

	return $result
}


######################################################################
# Grant full control to the log directory for the service account 

function ConfigureLogDirectoryAccess
{
	$logDirectory = GetConfigValue "LogDir"

	if (!(Test-Path $logDirectory -PathType Container)) {
		New-Item $logDirectory -type Directory | Out-Null
	}

	try
	{
		$acl = Get-Acl $logDirectory

		(, "XenAppServiceAccount") | %{
			$ident = GetConfigValue $_

			Log "Granting Full Control rights for '$ident' to '$logDirectory'"
			$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ident, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
			$acl.AddAccessRule($rule)
		}

		Set-Acl $logDirectory $acl
	}
	catch
	{	
		Log "Error setting permissions on log directory: $_" -level "Error"
		return $false
	}

	return $true
}
