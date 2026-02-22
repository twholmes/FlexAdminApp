###########################################################################
# Copyright (C) 2015-2018 Flexera
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
#

function ConfigureIISFeaturesForAnalytics
{
	Log "Configuring IIS features for Flexera Analytics"
	
	Import-Module ServerManager

	$restartNeeded = $false

	$features = (
		"Web-Server", "Web-WebServer",

		# Common HTTP Features
		"Web-Common-Http", "Web-Static-Content", "Web-Default-Doc",
		"Web-Dir-Browsing", "Web-Http-Errors", "Web-Http-Redirect",

		# Application Development
		"Web-App-Dev", "Web-CGI", "Web-ISAPI-Ext", "Web-ISAPI-Filter",

		# Health and Diagnostics
		"Web-Health", "Web-Http-Logging",

		# Security
		"Web-Security", "Web-Basic-Auth", "Web-Filtering", "Web-Windows-Auth",

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

	if ($restartNeeded) {
		Log "WARNING: System restart is needed to complete configuration of IIS features" -level "Warning"
	}

	Log "Done IIS feature configuration"
	return $true
}


###########################################################################
#

function GetCognosDispatcherPort
{
	# The Cognos dispatcher port is hard-coded in the FNMS
	# installer; it is not configurable. If/when it is made
	# configurable, this function might call GetConfigValue to get
	# the port number.

	return "9300"
}


###########################################################################
#

function InstallAnalytics
{
	if ((GetConfigValue 'DoMultiTenantInstall') -eq 'Y') {
		Log "" -level Error
		Log "ERROR: FlexNet Manager Suite has been configured in multi-tenant mode, and Flexera Analytics has also been selected to be installed." -level Error
		Log "" -level Error
		Log "This combination is not supported. Either you must install FlexNet Manager Suite in single-tenant mode, or you must not install Flexera Analytics." -level Error
		Log "" -level Error
		return $false
	}

	$supportDir = Join-Path (GetConfigValue "FNMSDownloadDir") "Support"

	# Files in the support directory often end up in a 'blocked' state after being downloaded from an
	# untrusted Internet site. We unblock these files here to seek to avoid failures while running the
	# config script.
	Get-ChildItem -Recurse $supportDir | Unblock-File

	# Use FullName for TEMP path to ensure $tempsd does *not* use any 8.3-style filename components (which subsequent scripting below can't handle)
	$tempsd = Join-Path (Get-Item $env:TEMP).FullName ([guid]::NewGuid())

	# Copy the support files to a temporary location so that they can be configured
	try {
		Log "Copying '$supportDir' to '$tempsd'"
		Copy-Item $supportDir $tempsd -Recurse -Force -ErrorAction Stop
	}
	catch {
		Log "ERROR: Copying '$supportDir' to '$tempsd' failed" -level Error
		Log "" -level Error
		$error[0] | Log -level Error

		return $false
	}

	try {
		$templateConfigFile = Join-Path $supportDir "CognosConfigProperties.xml"
		$tempConfigFile = Join-Path $tempsd "CognosConfigProperties.xml"

		if (!(SetCognosConfigProperties $templateConfigFile $tempConfigFile)) {
			return $false
		}

		Push-Location $tempsd
		try {
			$installer = Join-Path (GetConfigValue "AnalyticsInstallerDir") "analytics-installer-1.2.2-win.exe"
			$CognosInstallerRepoZipPath = Join-Path (GetConfigValue "AnalyticsInstallerDir") "ca_srv-11.0.13-2201052300-winx64h.zip"

			Log ""
			Log "Running Flexera Analytics install script:"
			Log "cd `"$tempsd`""
			Log ".\InstallCognos.ps1 -CognosInstallerFilePath $installer"
			& .\InstallCognos.ps1 -CognosInstallerFilePath $installer $CognosInstallerRepoZipPath | Log
		}
		catch {
			Log "" -level Error
			Log "ERROR: The Flexera Analytics install script failed: $_" -level Error

			return $false
		}
		finally {
			Pop-Location
		}

		if ((GetConfigValue 'InstallBatchServerComponents') -eq 'N') {
			# The following steps cannot be automated; they require a human, so give a human some advice...

			Log @"
***********************************************************************************************************************
IMPORTANT: To complete the configuration of the Flexera Analytics reporting package, execute the following
flexadmin target on the FlexNet Manager Suite batch server ($(GetConfigValue "FNMSBatchServerFQDN")):

.\flexadmin.ps1 ExecuteAnalyticsPackageImport
***********************************************************************************************************************

"@ -level Warning
		}
		
		return $true
	}
	finally {
		Remove-Item $tempsd -Recurse -Force -ErrorAction Continue
	}
}


###########################################################################
# Set the configuration properties for the InstallCognos.ps1 script

function SetCognosConfigProperties([string]$source, [string]$dest)
{
	Log "Setting properties in the Cognos config properties file: $dest"
	Log "Template file: $source"

	# Set the configuration nodes in $dest to be modified.
	# Adding these details that we already know allows the config script
	# to proceed without having to obtain so much input from the user.

	$Params = @{ }

	$ContentStoreDatabaseLocation = GetConfigValue "FNMSDBServer"
	# Cognos requires that server name and port number are separated by a ":" rather than ",", so this transform is applied.
	$ContentStoreDatabaseLocation = $ContentStoreDatabaseLocation -replace ",", ":"
	# Cognos requires the DB server must contain either a port or named instance. If neither is provided, add default port.
	if (!($ContentStoreDatabaseLocation -match '[:\\]')) {
		$ContentStoreDatabaseLocation = "$($ContentStoreDatabaseLocation):1433"
	}

	$ContentStoreDBName = GetConfigValue "ContentStoreDBName"

	$FNMSBatchServerLocation = "http://$(GetConfigValue "FNMSBatchServerFQDN")" # Only http (not https) is supported
	$CognosServerURI = "$(GetConfigValue "FNMSUserWebAccessProtocol")://$(GetConfigValue "AnalyticsServerFQDN")"
	$CognosServerURI = "$($CognosServerURI):$(([System.URI]$CognosServerURI).Port)" # Add port, which Analytics installer mandates is in the URI
	$CognosServerDispatcherURI = "http://$(GetConfigValue "AnalyticsServerFQDN"):$(GetCognosDispatcherPort)" # Only http (not https) is supported
	$CognosServiceMaxMemory = [int](GetConfigValue "CognosMaxMemoryGB") * 1024

	$Params += @{
		"/properties/property[@name='FNMSBatchServerLocation']" = @{value = $FNMSBatchServerLocation};
		"/properties/property[@name='ContentStoreDatabaseLocation']" = @{value = $ContentStoreDatabaseLocation};
		"/properties/property[@name='ContentStoreDatabaseName']" = @{value = GetConfigValue "ContentStoreDBName"};
		"/properties/property[@name='CognosInstallationPath']" = @{value = GetConfigValue "AnalyticsInstallDir"};
		"/properties/property[@name='CognosServerURI']" = @{value = $CognosServerURI};
		"/properties/property[@name='CognosServerDispatcherURI']" = @{value = $CognosServerDispatcherURI};
		"/properties/property[@name='CognosServiceMaxMemory']" = @{value = $CognosServiceMaxMemory};
	}

	if ((GetConfigValue "InstallWebAppServerComponents") -ne "Y") {
		$MachineKeyValidationKey = GetConfigValue "WebAppServerMachineKeyValidationKey"
		$MachineKeyDecryptionKey = GetConfigValue "WebAppServerMachineKeyDecryptionKey"

		$Params += @{
			"/properties/property[@name='MachineKeyValidationKey']" = @{value = $MachineKeyValidationKey};
			"/properties/property[@name='MachineKeyDecryptionKey']" = @{value = $MachineKeyDecryptionKey};
		}
	}

	# Get web service account credentials
	$webSvcCred = GetCredentials `
		"Requesting credentials for the service account used Cognos' IIS application pools ..." `
		"IIS application pool account credentials" `
		"Enter user credentials for Cognos' IIS application pools" `
		(GetConfigValue "FNMSServiceAccount")

	if (!$webSvcCred) { # Cancelled?
		Log "`tConfiguration cancelled by user"
		return $false
	}

	# Get service account credentials
	$cred = GetCredentials `
		"Requesting credentials for the service account used for the IBM Cognos service..." `
		"Service account credentials" `
		"Enter user credentials for the IBM Cognos service" `
		(GetConfigValue "FNMSServiceAccount")

	if (!$cred) { # Cancelled?
		Log "`tConfiguration cancelled by user"
		return $false
	}

	$Params += @{
		"/properties/property[@name='CognosServiceUserName']" = @{value = $cred.UserName};
		"/properties/property[@name='CognosServicePassword']" = @{value = $cred.GetNetworkCredential().Password};
		"/properties/property[@name='AppPoolUserName']" = @{value = $webSvcCred.UserName};
		"/properties/property[@name='AppPoolPassword']" = @{value = $webSvcCred.GetNetworkCredential().Password};
	}


	# Perform the updates
	if (!(GenerateXMLFromTemplate $source $dest $Params)) {
		return $false
	}

	Log ""
	Log "Adding 'Logon as a Batch Job' right to $($cred.UserName)"
	AddPrivileges $cred.UserName "SeBatchLogonRight"
	
	if ($webSvcCred.UserName -ne $cred.UserName) {
		Log ""
		Log "Adding 'Logon as a Batch Job' right to $($webSvcCred.UserName)"
		AddPrivileges $webSvcCred.UserName "SeBatchLogonRight"
	}

	if (!(EnsureIsLocalAdmin $cred.UserName)) {
		return $false
	}
	
	return $true
}


# Ensure a specified user account is a member of the local Administrators group
function EnsureIsLocalAdmin([string]$user)
{
	try {
		$sid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544") # Well-known SID for local Administrators group
		$localAdminsGroupName = $sid.Translate([System.Security.Principal.NTAccount]).Value
		$admins = [ADSI]"WinNT://$(hostname)/$($localAdminsGroupName.Split("\")[1])"

		$isMember = $false
		$admins.Invoke("Members") | %{
			$isMember = $isMember -or $_.GetType().InvokeMember("Name", "GetProperty", $null, $_, $null) -eq $user.Split("\")[1]
		}
	} 
	catch {
		Log "ERROR: Unable to determine whether $user is a member of $($localAdminsGroupName): $_" -level Error
		return $false
	}
	
	if (!$isMember) {
		Log "The user account $user is not a member of the $($localAdminsGroupName); adding membership"

		try {
			$result = $admins.Add("WinNT://$($user -replace "\\", "/")")
		}
		catch {
			Log "ERROR: Unable to add $user to $($localAdminsGroupName): $_" -level Error
			return $false
		}

		Log "`tGroup membership added"
	}
	
	return $true
}


###########################################################################
#

function RunFNMSCognosConfigScript
{
	$supportDir = Join-Path (GetConfigValue "FNMSDownloadDir") "Support"
	$templateConfigFile = Join-Path $supportDir "Config\FNMS Cognos Config.xml"
	$tempConfigFile = [System.IO.Path]::GetTempFileName()

	# Running Config.ps1 if the file is in a path that contains a '$' in its name (for example, if the script is run from a file
	# share like \\server\d$\downloads) does not work: when getting a variable value for the script path, the
	# GetActualDefaultValue function in ConfigHelper.ps1 sees the '$' and thinks it is a PowerShell variable reference, and
	# returns a bogus value.
	#
	# Check for a bad path and complain!

	if ($supportDir.Contains("`$")) {
		Log "ERROR: The download directory path '$supportDir' contains the character '$'. The Config.ps1 script is unable to handle paths with this character." -level Error
		Log "" -level Error
		Log "You should:" -level Error
		Log "1. Move the downloaded directory to another path" -level Error
		Log "2. Edit the fnms.settings file to remove the current value specified for the 'FNMSDownloadDir' setting" -level Error
		Log "3. Restart this script" -level Error

		return $false
	}

	SetFNMSCognosConfigAnswers $templateConfigFile $tempConfigFile
	Log ""

	Push-Location $supportDir

	try {
		$configScript = Join-Path $supportDir "Config.ps1"
		Log "Executing: & `"$configScript`" `"$tempConfigFile`" forceUpdateConfig"
		& $configScript $tempConfigFile forceUpdateConfig
	}
	finally {
		Log "Config script execution completed"

		$logFile = "config.log" # Config.ps1 uses a hard-coded log file name in the current directory
		if (Test-Path $logFile -pathType leaf) {
			Copy-Item $logFile (Join-Path (GetConfigValue "LogDir") ("FNMSCognosConfig-forceUpdateConfig_{0}.log" -f (Get-Date -format "yyyyMMdd_HHmmss")))
		}
		Remove-Item $tempConfigFile
		Pop-Location
	}

	return $true
}

function SetFNMSCognosConfigAnswers([string] $templateConfigFile, [string] $outConfigFile)
{
	Log "Generating Cognos configuration file '$outConfigFile' from template '$templateConfigFile'"

	# Set the configuration nodes in $templateConfigFile to be modified.
	# Adding these details that we already know allows the config script
	# to proceed without having to obtain so much input from the user.

	$Params = @{ }

	$webAccessProtocol = GetConfigValue "FNMSUserWebAccessProtocol"
	$reportServerFQDN = GetConfigValue "AnalyticsServerFQDN"

	$Params += @{
		"/Configuration/Server/Parameters/Add[@Name='biPortalUrl']" = @{"DefaultValue" = "$webAccessProtocol`://$reportServerFQDN"};
	}

	# Perform the updates
	$configXml = [xml](Get-Content $templateConfigFile)
	foreach ($param in $Params.GetEnumerator())
	{
		Log "`tConfiguring settings matching $($param.Name)"
		$i = 0
		foreach ($node in $configXml.SelectNodes($param.Name)) {
			++$i
			Log "`t`tMatch $i"

			$attributes = $param.Value
			foreach ($attribute in $attributes.GetEnumerator()) {
				$attributeValueForLogging = $attribute.Value
				Log "`t`t`tSet attribute $($attribute.Name) to: $attributeValueForLogging"

				$node.SetAttribute($attribute.Name, $attribute.Value)
			}
		}
	}

	# Generate installer response file
	$configXml.Save($outConfigFile)
}


###########################################################################
# This function calls the Cognos package import utility which is installed 
# on the batch server. The utility contacts the Cognos server 
# dispatcher and requests it to import the FNMS reporting package.
#
# FlexNet Analytics must be installed and configured prior to running this.

function ExecuteAnalyticsPackageImport
{
	$id = GetFNMSInstallDir
	if (!$id) {
		Log "ERROR: FlexNet Manager Suite is not installed. The Flexera Analytics reporting package must be registered from the FlexNet Manager Suite batch server." -level Error
		return $false
	}

	$cogPkgImport = Join-Path $id "Cognos\BusinessReportingAuthenticationService\bin\CognosPackageImportConsole.exe"
	
	if (!(Test-Path $cogPkgImport -PathType Leaf)) {
		Log "ERROR: The Flexera Report Designer Package Import Utility could not be found at '$cogPkgImport'" -level Error
		return $false
	}
	
	# Set the dispatch URL in the registry
	$key = GetMGSRegKey
	if (!$key)
	{
		Log "ERROR: Failed to open 'ManageSoft' registry key" -level Error
		return $false
	}

	# Protocol must be "http" (see FNMS-32703)
	$dispatchURL = "http://$(GetConfigValue "AnalyticsServerFQDN"):$(GetCognosDispatcherPort)/p2pd/servlet/dispatch"

	# Run the import utility
	Log "Setting the Flexera Analytics dispatch URL to $dispatchURL"
	$ok = ExecuteProcess -exe $cogPkgImport @("set", "-d", $dispatchURL)

	if (!$ok) {
		Log "ERROR: Failed to set Flexera Analytics dispatch URL" -level Error
		return $false
	}

	Log "Importing the Flexera Analytics reports package"
	$ok = ExecuteProcess -exe $cogPkgImport @("import")
	
	if (!$ok) {
		Log "Failed to import the reports package" -level Error

		Log @"

Consider the following points:

* Ensure the account you are logged on as is a member of a FlexNet Manager Suite role that is configured with access
  to the 'Business reporting portal > Analytics Administrator' feature. See the 'Import the Sample Reporting Package'
  topic in the 'Installing FlexNet Manager Suite' guide for more details.

* Ensure Flexera Analytics is installed and running. If it is not yet installed, execute the following on
  $(GetConfigValue "AnalyticsServerFQDN") before continuing the install here:
  .\flexadmin.ps1 InstallAll

* The following troubleshooting steps may help if the reports package import fails with an error message like
  'FlexNet Manager Platform was unable to log in to the Cognos server':

  1. Log onto the server $(GetConfigValue "FNMSBatchServerFQDN") and run Internet Explorer.

  2. Browse to http://localhost/BusinessReportingAuthentication/BusinessReportingAuthenticationService.asmx?op=GetCognosReportingAccessByOperatorLogin

  3. Enter the following value for the 'operatorLogin' parameter: $(whoami) 
     Leave the 'operatorToken' and 'tenantUID' parameters blank.

  4. Click the 'Invoke' button.

  5. Inspect the output from running the method and check for any indication of an error or problem.
"@ -level Warning

		return $false
	}

	return $true
}


###########################################################################
#

function UninstallAnalytics
{
	Log "Uninstalling Flexera Analytics"

	$keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\IBM Cognos Analytics"
	$key = Get-Item $keyPath -ErrorAction SilentlyContinue

	if (!$key) {
		$keyPath = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\IBM Cognos Analytics"
		$key = Get-Item $keyPath -ErrorAction SilentlyContinue
	}

	if (!$key) {
		Log "WARNING: Skipping uninstall of Flexera Analytics as it does not appear to be installed (registry key '$keyPath' does not exist)" -level Warning
		return $true
	}

	# Sample uninstall command value:
	# "C:\Program Files\ibm\cognos\analytics\Uninstall_IBM_Cognos_Analytics.exe"

	$uninstallCommand = $key.GetValue("UninstallString")

	$ok = ExecuteProcess $uninstallCommand

	if (!$ok) {
		Log "ERROR: Failed to uninstall Flexera Analytics" -level Error
		return $false
	}

	Log "Successfully uninstalled Flexera Analytics"
	return $true
}
