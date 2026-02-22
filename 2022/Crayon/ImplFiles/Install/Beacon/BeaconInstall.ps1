###########################################################################
# This PowerShell script can be used with flexadmin.ps1 to install
# FlexNet Beacon software components on a computer running
# Windows Server 2008 R2+.
#
# Copyright (C) 2015-2018 Flexera
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
#

function ConfigureIISFeaturesForBeacon
{
	Log "Configuring IIS features for FlexNet Beacon"

	Import-Module ServerManager

	$restartNeeded = $false

	$features = (
		"Web-Server", "Web-WebServer",

		# Common HTTP Features
		"Web-Common-Http", "Web-Static-Content", "Web-Default-Doc",
		"Web-Dir-Browsing", "Web-Http-Errors",

		# Application Development
		"Web-App-Dev", "Web-CGI", "Web-ISAPI-Ext", "Web-ISAPI-Filter",

		# Health and Diagnostics
		"Web-Health", "Web-Http-Logging",

		# Security
		"Web-Security", "Web-Basic-Auth", "Web-Windows-Auth",

		# Performance
		"Web-Performance", "Web-Stat-Compression", "Web-Dyn-Compression",

		# Management Tools
		"Web-Mgmt-Tools", "Web-Mgmt-Console"
	)

	if (Get-WindowsFeature Web-Asp-Net45) { 
		$features += (
			"Web-Asp-Net45", "Web-Net-Ext45"
		)
	} elseif (Get-WindowsFeature Web-Asp-Net) {
		$features += (
			"Web-Asp-Net", "Web-Net-Ext"
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

	$restartNeeded = $restartNeeded -or $result.RestartNeeded

	$result = Remove-WindowsFeature Web-DAV-Publishing
	$restartNeeded = $restartNeeded -or $result.RestartNeeded

	if ($restartNeeded) {
		Log "WARNING: System restart may be needed to complete configuration of IIS features" -level Warning
	}

	Log "Done IIS feature configuration"
	return $true
}


###########################################################################

function InstallBeacon
{
	if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
		Log "ERROR: This script must be run with local administrator rights" -level Error
		return $false
	}

	Log "Checking if the FlexNet Beacon component is already installed (this may take a few moments)..."
	$installRecord = Get-WmiObject Win32_Product | Where {$_.Name -match 'FlexNet Beacon' -or $_.Name -match 'Flexera Inventory Beacon' }

	if ($installRecord) {
		Log "NOTE: Version $($installRecord.Version) of the FlexNet Beacon component appears to already be installed, and will not be automatically re-installed."
		return $true
	}
	
	$pattern = Join-Path (GetConfigValue "FNMSDownloadDir") "Installers\FlexNet Beacon\BeaconInstaller*.exe"
	$installer = ls $pattern
	if (!$installer) {
		Log "ERROR: Failed to find beacon installer at $pattern" -level Error
		return $false
	}

	if ($installer.Count -gt 1) {
		Log "ERROR: Found multiple beacon installers matching pattern $($pattern):" -level Error
		$installer | %{ Log "`t$_" -level Error }
		return $false
	}

	Log "Installing FlexNet Beacon"

	$msiexecArgs = (
		"/qb+",
		"ALLUSERS=1",
		"ADDLOCAL=ALL",
		"REBOOT=ReallySuppress",
		"FNMPWEBUIURL=$(GetConfigValue "FNMSUserWebAccessProtocol")://$(GetConfigValue "FNMSWebServerFQDN")/Suite"
	)

	$installDir = GetConfigValue "BeaconInstallDir"
	if ($installDir) {
		$msiexecArgs += "INSTALLDIR=\`"$installDir\`""
	}

	if ((GetConfigValue "InstallBatchServerComponents") -eq "Y") {
		# Beacon scheduled tasks are not required if the beacon also has batch server components installed
		$msiexecArgs += "CONFIGURESCHEDS=FALSE"
	} else {
		$svcAccount = GetConfigValue "FNMSServiceAccount"

		$cred = GetCredentials `
			"Requesting credentials for the service account to be used to run the beacon scheduled tasks..." `
			"Scheduled task credentials" `
			"Enter user credentials for running the FlexNet Beacon scheduled tasks" `
			$svcAccount

		if (!$cred) { # Cancelled?
			Log "Configuration cancelled by user"
			return $false
		}

		$schedPasswordArgument = "SCHEDPASSWORD=\`"$($cred.GetNetworkCredential().Password)\`""

		$msiexecArgs += (
			"SCHEDUSERNAMEMODE=OTHER",
			"SCHEDUSERNAME=\`"$svcAccount\`"",
			$schedPasswordArgument
		)
	}

	$logDir = Split-Path (GetLogFile)
	if ($logDir) {
		$log = Join-Path $logDir ("FlexNetBeacon-Install_{0}.log" -f (Get-Date -format "yyyyMMdd_HHmmss")) # Don't use a space in this path; the command line doesn't cope with it
		$msiexecArgs += ("/l*v", "\`"$log\`"")
		Log "`tInstallation log file is being written to: $log"
	}

	# NB. The scheduled task password is embedded in this command line and shown in logging.
	#
	# It would be good to enhance the ExecuteProcess function to be able to hide it (e.g. by passing a
	# regular expression used to match and hide info from logging). This can't be done using the
	# -hiddenArguments option to ExecuteProcess as that option only matches on a complete argument
	# text, while in this scenario the password is embedded within a long argument containing many options.

	$ok = ExecuteProcess "`"$installer`" /s /v`"$msiexecArgs`"" -goodExitCodes (0, 3010) # -hiddenArguments ($schedPasswordArgument)
	if (!$ok) {
		Log "" -level Error
		Log "ERROR: Installation of FlexNet Beacon failed" -level Error
		Log "Check log file for details: $log" -level Error

		return $false
	}

	Log "Installation of FlexNet Beacon succeeded"

	return $true
}


###########################################################################

function UninstallBeacon
{
	$installRecord = Get-WmiObject Win32_Product | Where {$_.Name -match 'FlexNet Beacon' }
	if (!$installRecord) {
		$installRecord = Get-WmiObject Win32_Product | Where {$_.Name -match 'Flexera Inventory Beacon' }
	}
	
	if (!$installRecord) {
		Log "NOTE: The FlexNet Beacon component does not appear to be installed; no uninstall attempt will be made"
		return $true
	}
	
	Log "Version $($installRecord.Version) of the FlexNet Beacon is currently installed"
	
	Log "Uninstalling FlexNet Beacon"
	
	$msiexecArgs = (
		"/qb+",
		"/x", "$($installRecord.IdentifyingNumber)"
	)

	$logDir = Split-Path (GetLogFile)
	if ($logDir) {
		$log = Join-Path $logDir ("FlexNet Beacon-Uninstall_{0}.log" -f (Get-Date -format "yyyyMMdd_HHmmss"))
		$msiexecArgs += "/l*v"
		$msiexecArgs += "`"$log`""
		Log "`tUninstallation log file is being written to: $log"
	}

	$ok = ExecuteProcess "msiexec.exe" $msiexecArgs -goodExitCodes (0, 3010)
	if (!$ok) {
		Log "" -level Error
		Log "ERROR: Uninstallation of FlexNet Beacon failed" -level Error
		Log "Check log file for details: $log" -level Error

		return $false
	}

	Log "Uninstallation of FlexNet Beacon succeeded"

	return $true
}


###########################################################################
# Configures non-default registry entry values as required for good beacon operation.

function ConfigureBeaconRegistrySettings
{
	$key = GetMGSRegKey
	if (!$key)
	{
		Log "ERROR: Failed to open 'ManageSoft' registry key" -level Error
		return $false
	}

	try {
		Log "Configuring values under '$key':"

		# Default AD timeout values are 30 seconds, which tends to be too small for AD import
		# operations to work reliably in large environments. The default may change in a future
		# release (see FNMS-48790).

		New-Item -Path "$($key.PSPath)\ActiveDirectoryImporter\CurrentVersion" -Force | Out-Null

		Log "`tActiveDirectoryImporter\CurrentVersion\RequestTimeout=300"
		Set-ItemProperty -Path "$($key.PSPath)\ActiveDirectoryImporter\CurrentVersion" -Name RequestTimeout -Value "300" -ErrorAction Stop

		Log "`tActiveDirectoryImporter\CurrentVersion\ConnectionTimeout=300"
		Set-ItemProperty -Path "$($key.PSPath)\ActiveDirectoryImporter\CurrentVersion" -Name ConnectionTimeout -Value "300" -ErrorAction Stop
	}
	catch {
		Log "Error setting registry values: $_" -level Error
		return $false
	}
	finally {
		$key.Close()
	}

	return $true
}
