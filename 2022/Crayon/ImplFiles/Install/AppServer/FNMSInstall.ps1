###########################################################################
# Copyright (C) 2015-2018 Flexera
###########################################################################


###########################################################################
#

function PreFNMSInstallValidation([string]$msi)
{
	Log "Validating environment prior to installing FlexNet Manager Suite"

	if (!(Test-Path $msi)) {
		Log "" -level Error
		Log "MSI file does not exist in specified location: $msi" -level Error
		Log "Place the MSI file in this location, or modify flexadmin configuration settings" -level Error
		Log "" -level Error
		return $false
	}


	if ((GetConfigValue "InstallBatchServerComponents") -eq "Y") {
		# Check if osql.exe is in the PATH

		$FoundOSQL = $false
		$env:Path.Split(";") | foreach {
			if ($_ -and (Test-Path (Join-Path $_ "osql.exe"))) { $FoundOSQL = $true }
		}

		if (!$FoundOSQL) {
			Log "" -level Error
			Log "ERROR: SQL Server osql.exe tool not found in PATH" -level Error
			Log "Please install the SQL client tools or update the PATH environment variable and try this script again" -level Error
			Log "" -level Error

			return $false
		}
	}

	Log "No environmental problems found for FlexNet Manager Suite installation"
	return $true
}


###########################################################################
#

function ConfigureWindowsFeaturesForFNMS
{
	Log "Configuring Windows features required for FlexNet Manager Suite"
	
	Import-Module ServerManager

	$features = (
		"Web-Server", "Web-WebServer",

		# Common HTTP Features
		"Web-Common-Http", "Web-Static-Content", "Web-Default-Doc",
		"Web-Dir-Browsing", "Web-Http-Errors", "Web-Http-Redirect",

		# Application Development
		"Web-App-Dev", "Web-CGI", "Web-ISAPI-Ext",
		"Web-ISAPI-Filter",

		# Health and Diagnostics
		"Web-Health", "Web-Http-Logging",

		# Security
		"Web-Security", "Web-Basic-Auth", "Web-Filtering", "Web-Windows-Auth",

		# Performance
		"Web-Performance", "Web-Stat-Compression", "Web-Dyn-Compression",

		# Management Tools
		"Web-Mgmt-Tools", "Web-Mgmt-Console"
	)

	if (Get-WindowsFeature NET-Framework-45-Features) { 
		$features += (
			"Net-Framework-45-Features", "Net-Framework-45-Core", "Net-Framework-45-ASPNET",
			"Net-WCF-Services45", "Net-WCF-TCP-PortSharing45",

			# Configure ASP.NET in IIS
			"Net-Framework-45-ASPNET", "Web-Asp-Net45", "Web-Net-Ext45"
		)
	} elseif (Get-WindowsFeature NET-Framework) {
		$features += (
			"NET-Framework", "Web-Asp-Net", "Web-Net-Ext"
		)
	}

	Log ""
	Log "Adding Windows features:"
	$features | %{ Log "`t$_" }

	$result = Add-WindowsFeature $features

	if (!$result.Success) {
		Log "ERROR: Failed to configure IIS features" -level Error
		return $false
	}

	$restartNeeded = $result.RestartNeeded

	$features = "Web-DAV-Publishing"
	
	Log ""
	Log "Removing Windows features:"
	$features | %{ Log "`t$_" }

	$result = Remove-WindowsFeature $features
	$restartNeeded = $restartNeeded -or $result.RestartNeeded

	Log ""

	if ($restartNeeded) {
		Log "NOTE: System restart may be needed to complete configuration of IIS features" -level Warning
	}

	Log "Completed Windows feature configuration"
	return $true
}



###########################################################################
#

function InstallFNMSAppServer
{
	$id = GetFNMSInstallDir
	if ($id) {
		Log "WARNING: FlexNet Manager Suite appears to already be installed, and will not be automatically re-installed." -level Warning
#		Log "To uninstall FlexNet Manager Suite, try the 'UninstallFNMSAppServer' target." -level Warning
		return $true
	}

	$installWebAppServer = GetConfigValue "InstallWebAppServerComponents"
	$installBatchServer = GetConfigValue "InstallBatchServerComponents"
	$installInvServer = GetConfigValue "InstallInventoryServerComponents"

	# To maintain the feature names listed here, see the Feature table in the FNMS MSI package
	
	Log "FlexNet Manager Suite application server components to be installed:"
	$installFeatures = @()
	if ($installWebAppServer -eq "Y") {
		Log "`tWeb application server"
		$installFeatures += "WebUI"
	}
	if ($installBatchServer -eq "Y") {
		Log "`tBatch server"
		$installFeatures += ("BatchScheduler", "BeaconService", "CognosAuthentication", "ServiceNowExporter")

		# Current FNMS releases (as of FNMS 2018 R1) do not support a batch server whose hostname is too long.
		# The documented limit is 13 characters, but experience has shown that names of at least 14 characters definitely do work.
		# See Jira entry FNMS-28332 for details.
		if ($env:COMPUTERNAME.length -gt 14) {
			Log "ERROR: The FlexNet Manager Suite Batch Server must be installed on a computer whose hostname is no more than 14 characters long" -level Error
			return $false
		}
	}
	if ($installInvServer -eq "Y") {
		Log "`tInventory server"
		$installFeatures += ("InventoryServer", "Importers", "Inventory", "Operational", "PackagingFactory")
	}

	if (!$installFeatures) {
		Log "NOTE: No FlexNet Manager Suite application server components are configured to be installed on this server"
		return $true
	}


	$msi = Join-Path (GetConfigValue "FNMSDownloadDir") "Installers\FlexNet Manager Suite\FlexNet Manager Suite Server.Msi"

	if (!(PreFNMSInstallValidation $msi)) {
		return $false
	}

	$log = Join-Path (GetConfigValue "LogDir") ("FlexNet Manager Suite Server-install_{0}.log" -f (Get-Date -format "yyyyMMdd_HHmmss"))

	$msiexecArgs = (
		"/qb+",
		"/l*v", "`"$log`"",
		"/i", "`"$msi`"",
		"ALLUSERS=1",
		"ADDLOCAL=$($installFeatures -join ',')"
	)

	$installDir = GetConfigValue "FNMSInstallDir"
	if ($installDir) {
		$msiexecArgs += "INSTALLDIR=`"$installDir`""
	}

	if ($installWebAppServer -eq "Y") {
		# No additional arguments needed
	}
	
	if ($installBatchServer -eq "Y") {
		$cred = GetCredentials `
			"Requesting credentials for the service account to perform batch processing..." `
			"Batch processing credentials" `
			"Enter user credentials for running FlexNet Manager Suite batch processing" `
			(GetConfigValue "FNMSServiceAccount")

		if (!$cred) { # Cancelled?
			Log "Configuration cancelled by user"
			return $false
		}

		Log "`tAdding 'Logon as a Service' right to $($cred.UserName)"
		AddPrivileges $cred.UserName "SeServiceLogonRight"

		$svcUserName = $cred.UserName
		$svcUserPasswordArgument = "BATCHPROCESSPASSWORD=`"$($cred.GetNetworkCredential().Password)`""

		$msiexecArgs += (
			"BASEDIR=`"$(GetConfigValue "FNMSStagingDir")`"",
			"BATCHPROCESSUSERNAME=`"$svcUserName`"",
			$svcUserPasswordArgument
		)
	}

	if ($installWebAppServer -eq "Y" -or $installBatchServer -eq "Y") {
		$msiexecArgs += (
			"DATAIMPORTDIR=`"$(GetConfigValue "FNMSDataImportDir")`""
		)
	}
	
	if ($installInvServer -eq "Y") {
		$msiexecArgs += (
			"WAREHOUSEDIR=`"$(GetConfigValue "FNMSInvSvrPkgRepositoryDir")`"",
			"INCOMINGDIR=`"$(GetConfigValue "FNMSInvSvrIncomingDir")`""
		)
	}

	Log ""
	Log "Installing FlexNet Manager Suite components:"
	Log ""

	$ok = ExecuteProcess "msiexec.exe" $msiexecArgs -goodExitCodes (0, 3010) -hiddenArguments ($svcUserPasswordArgument)
	if (!$ok) {
		Log "" -level Error
		Log "ERROR: Installation of FlexNet Manager Suite components failed" -level Error
		Log "Check log file for details: $log" -level Error

		return $false
	}

	Log "Installation of FlexNet Manager Suite components succeeded"

	return $true	
}


###########################################################################
#

function UninstallFNMS
{
	if (!(GetFNMSInstallDir)) {
		Log "WARNING: FlexNet Manager Suite components do not appear to be installed. Skipping attempt to uninstall." -level Warning
		return $true
	}

	$dlDir = GetConfigValue "FNMSDownloadDir"
	$supportDir = Join-Path $dlDir "Support"
	$configFile = Join-Path $supportDir "Config\FNMS Windows Authentication Config.xml"

	# Files in the support directory often end up in a 'blocked' state after being downloaded from an
	# untrusted Internet site. We unblock these files here to seek to avoid failures while running the
	# config script.
	Get-ChildItem -Recurse $supportDir | Unblock-File

	Push-Location $supportDir	

	try {
		$configScript = Join-Path $supportDir "Config.ps1"
		Log "Executing: & $configScript $configFile removeConfig"
		& $configScript $configFile removeConfig
	}
	catch {
		Log "" -level Error
		Log "ERROR: Failed to execute config script: $_" -level Error
		return $false
	}
	finally {
		Log "Config script execution completed"

		$logFile = "config.log" # Config.ps1 uses a hard-coded log file name in the current directory
		if (Test-Path $logFile -pathType leaf) {
			Copy-Item $logFile (Join-Path (GetConfigValue "LogDir") ("FNMSConfig-removeConfig_{0}.log" -f (Get-Date -format "yyyyMMdd_HHmmss")))
		}
		Pop-Location
	}
	
	$msi = Join-Path $dlDir "Installers\FlexNet Manager Suite\FlexNet Manager Suite Server.Msi"
	$msiexecArgs = ("/qb+", "/x", "`"$msi`"")

	$logDir = Split-Path (GetLogFile)
	if ($logDir) {
		$log = Join-Path $logDir ("FlexNet Manager Suite Server-uninstall_{0}.log" -f (Get-Date -format "yyyyMMdd_HHmmss"))
		$msiexecArgs += "/l*v"
		$msiexecArgs += "`"$log`""
	}

	Log ""
	Log "Uninstalling FlexNet Manager Suite server components"
	Log ""

	$ok = ExecuteProcess "msiexec.exe" $msiexecArgs -goodExitCodes (0, 3010)
	if (!$ok) {
		Log "" -level Error
		Log "ERROR: Uninstall of FlexNet Manager Suite server components failed" -level Error
		Log "Check log file for details: $log" -level Error

		return $false
	}

	Log "Uninstall of FlexNet Manager Suite server components succeeded"

	return $true
}
