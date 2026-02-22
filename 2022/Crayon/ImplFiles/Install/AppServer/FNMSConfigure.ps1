###########################################################################
# Copyright (C) 2015-2017 Flexera Software
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
#

function ConfigureComplianceReaderTracing
{
	$cfgPath = Join-Path $env:ProgramData "Flexera Software\Compliance\Logging\ComplianceReader.config"
	Log "Configuring settings in '$cfgPath'"

	$subst = @{
		# Use yyyyMMdd rather than ddMMyyyy in log filenames
		"/log4net/appender[@name = 'file']/file" = @{ type = "log4net.Util.PatternString"; value = "%property{ComplianceLoggingPath}\ComplianceReader\%property{TenantUID}\importer%property{TenantUID}%property{Concurrent}-[%date{yyyyMMdd}]-[%processid].log" };
	}

	$ok = GenerateXMLFromTemplate $cfgPath $cfgPath $subst
	
	if ($ok) {
		Log "Tracing settings configured"
	}

	return $ok
}


###########################################################################
#

function ConfigureWebUITracing
{
	$cfgPath = Join-Path $env:ProgramData "Flexera Software\Compliance\Logging\WebUI.config"
	Log "Configuring settings in '$cfgPath'"

	$subst = @{
		# Include %aspnet-request values in logging
		"/log4net/appender[@name = 'file']/layout/conversionPattern" = @{ value = "[%-5p %d %5rms %aspnet-request{REQUEST_METHOD} %aspnet-request{URL} %aspnet-request{QUERY_STRING} %aspnet-request{REMOTE_USER} %-22.22c{1}] %m%n" };
	}

	$ok = GenerateXMLFromTemplate $cfgPath $cfgPath $subst
	
	if ($ok) {
		Log "Tracing settings configured"
	}

	return $ok
}


###########################################################################
# This function displays the Activation Wizard for the FNMS license key
# to be installed.

function DisplayActivationWizard
{
	$installBatchServer = GetConfigValue "InstallBatchServerComponents"
	if ($installBatchServer -ne "Y") {
		Log "Nothing to do: the Activation Wizard only needs to be run on the batch server"
		return $true # Nothing to do on this server
	}

	$id = GetFNMSInstallDir
	if (!$id) {
		Log "ERROR: FlexNet Manager Suite is not installed" -level Error
		return $false
	}

	$activationWizard = Join-Path $id "DotNet\bin\ManageSoft.Activation.Wizard.exe"

	if (!(Test-Path $activationWizard -PathType Leaf)) {
		Log "ERROR: The Activation Wizard could not be found at '$activationWizard'" -level Error
		return $false
	}

	Log "" -level Warning
	Log "**** The FlexNet Manager Suite Activation Wizard will shortly appear." -level Warning
	Log "**** Import your FlexNet Manager Suite license file and click OK." -level Warning
	Log "" -level Warning

	# Run the import utility
	$ok = ExecuteProcess $activationWizard

	if (!$ok) {
		Log "ERROR: Failed to run the Activation Wizard utility" -level Error
		return $false
	}

	return $true
}



###########################################################################
#

function RunFNMSConfigurationScript
{
	$supportDir = Join-Path (GetConfigValue "FNMSDownloadDir") "Support"

	# Running Config.ps1 on the "FNMS Windows Authentication.xml" file if the file is in a path that contains a '$' in its name
	# (for example, if the script is run from a file share like \\server\d$\downloads) does not work: when getting a variable
	# value for the script path, the GetActualDefaultValue function in ConfigHelper.ps1 sees the '$' and thinks it is a PowerShell
	# variable reference, and returns a bogus value.
	#
	# Check for a bad path and complain!

	if ($supportDir.Contains("`$")) {
		Log "ERROR: The download directory path '$supportDir' contains the character '$'. The Config.ps1 script is unable to handle paths with this character." -level Error
		Log "" -level Error
		Log "You should:" -level Error
		Log "1. Move the downloaded directory to another path" -level Error
		Log "2. Edit the fnms.settings file to remove the current value specified for the 'FNMSDownloadDir' setting" -level Error
		Log "3. Restart this script" -level Error
		Log "" -level Error

		return $false
	}

	# Check "Do not allow storage of passwords..." policy setting is disabled so that scheduled tasks can be configured
	$p = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name DisableDomainCreds -ErrorAction Ignore
	if ($p -and $p.DisableDomainCreds -ne 0) {
		Log "" -level Error
		Log "ERROR: The following security policy setting is currently enabled:" -level Error
		Log "Security Settings > Local Policies > Security Options > Network access: Do not allow storage of passwords and credentials for network authentication" -level Error
		Log "" -level Error
		Log "This setting must be disabled so Windows Task Scheduler tasks can run." -level Error
		Log "" -level Error

		return $false
	}

	$templateConfigFile = Join-Path $supportDir "Config\FNMS Windows Authentication Config.xml"
	$tempConfigFile = [System.IO.Path]::GetTempFileName()

	if (!(SetConfigAnswers $templateConfigFile $tempConfigFile)) {
		return $false
	}

	# Delete DB connection string registry entries so that Config.ps1 will re-configure them to expected values.
	# This is needed as Config.ps1 will not (at least as of the 2017 R2 release) overwrite existing
	# (possibly incorrect) values in these keys, even when the forceUpdateConfig parameter is used.
	#
	# See FNMS-23207 for details.
	Log "Deleting any existing database connection strings under HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\Reporter\CurrentVersion"
	("DatabaseConnectionString", "InventoryDatabaseConnectionString", "FNMPDWDatabaseConnectionString", "SnapshotDatabaseConnectionString") | %{
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\Reporter\CurrentVersion" -Name $_ -ErrorAction SilentlyContinue
	}

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
			Copy-Item $logFile (Join-Path (GetConfigValue "LogDir") ("FNMSConfig-forceUpdateConfig_{0}.log" -f (Get-Date -format "yyyyMMdd_HHmmss")))
		}

		Pop-Location
		Remove-Item $tempConfigFile
	}

	return $true
}


function SetConfigAnswers([string] $templateConfigFile, [string] $outConfigFile)
{
	Log "Generating FlexNet Manager Suite configuration file '$outConfigFile' from template '$templateConfigFile'"

	# Get service account credentials
	$cred = GetCredentials `
		"Requesting credentials for the service account used for scheduled tasks and IIS application pools..." `
		"Service account credentials" `
		"Enter user credentials for scheduled tasks and web applications" `
		(GetConfigValue "FNMSServiceAccount")

	if (!$cred) { # Cancelled?
		Log "`tConfiguration cancelled by user"
		return $false
	}

	$svcUserName = $cred.UserName
	$svcUserPassword = $cred.GetNetworkCredential().Password

	$webAccessProtocol = GetConfigValue "FNMSInternalWebAccessProtocol"
	$recServerFQDN = GetConfigValue "FNMSBatchServerFQDN"
	$invServerFQDN = GetConfigValue "FNMSInvServerFQDN"
	$dbServer = GetConfigValue "FNMSDBServer"
	$invDBServer = GetConfigValue "FNMSInvDBServer"
	$complianceDBName = GetConfigValue "FNMSComplianceDBName"
	$snapshotDBName = GetConfigValue "FNMSSnapshotDBName"
	$dwDBName = GetConfigValue "FNMSDataWarehouseDBName"
	$invDBName = GetConfigValue "FNMSInvDBName"

	# Set the configuration nodes in $templateConfigFile to be modified.
	# Adding these details that we already know allows the config script
	# to proceed without having to obtain so much input from the user.

	$Params = @{
		"/Configuration/Server/Identities/Add[@Name='BeaconAppPoolUser']" = @{UserName = $svcUserName; Password = $svcUserPassword};
		"/Configuration/Server/Identities/Add[@Name='BusinessReportingAuthUser']" = @{UserName = $svcUserName; Password = $svcUserPassword};
		"/Configuration/Server/Identities/Add[@Name='DLAppPoolUser']" = @{UserName = $svcUserName; Password = $svcUserPassword};
		"/Configuration/Server/Identities/Add[@Name='ExternalAPIAppPoolUser']" = @{UserName = $svcUserName; Password = $svcUserPassword};
		"/Configuration/Server/Identities/Add[@Name='InventoryScheduledTaskUser']" = @{UserName = $svcUserName; Password = $svcUserPassword};
		"/Configuration/Server/Identities/Add[@Name='ReconciliationScheduledTaskUser']" = @{UserName = $svcUserName; Password = $svcUserPassword};
		"/Configuration/Server/Identities/Add[@Name='SuiteAppPoolUser']" = @{UserName = $svcUserName; Password = $svcUserPassword};
		"/Configuration/Server/Identities/Add[@Name='RLAppPoolUser']" = @{UserName = $svcUserName; Password = $svcUserPassword};

		"/Configuration/Server/Parameters/Add[@Name='InventoryServerURL']" = @{"DefaultValue" = "$webAccessProtocol`://$invServerFQDN"};
		"/Configuration/Server/Parameters/Add[@Name='ReconciliationServerURL']" = @{"DefaultValue" = "$webAccessProtocol`://$recServerFQDN"};
		"/Configuration/Server/Parameters/Add[@Name='ReconciliationServer']" = @{"DefaultValue" = $recServerFQDN; PromptWithDefault = "False"};

		"/Configuration/Server/Parameters/Add[@Name='DWDatabaseName']" = @{"DefaultValue" = $dwDBName; AllowForceUpdate = ""};
		"/Configuration/Server/Parameters/Add[@Name='DWDatabaseServer']" = @{"DefaultValue" = $dbServer; AllowForceUpdate = ""};
		"/Configuration/Server/Parameters/Add[@Name='FNMSDatabaseName']" = @{"DefaultValue" = $complianceDBName; AllowForceUpdate = ""};
		"/Configuration/Server/Parameters/Add[@Name='FNMSDatabaseServer']" = @{"DefaultValue" = $dbServer; AllowForceUpdate = ""};
		"/Configuration/Server/Parameters/Add[@Name='IMDatabaseName']" = @{"DefaultValue" = $invDBName; AllowForceUpdate = ""};
		"/Configuration/Server/Parameters/Add[@Name='IMDatabaseServer']" = @{"DefaultValue" = $invDBServer; AllowForceUpdate = ""};
		"/Configuration/Server/Parameters/Add[@Name='SnapshotDatabaseName']" = @{"DefaultValue" = $snapshotDBName; AllowForceUpdate = ""};
		"/Configuration/Server/Parameters/Add[@Name='SnapshotDatabaseServer']" = @{"DefaultValue" = $dbServer; AllowForceUpdate = ""}
	}

	# Perform the updates
	if (!(GenerateXMLFromTemplate $templateConfigFile $outConfigFile $Params)) {
		return $false
	}

	Log ""
	Log "Adding 'Logon as a Batch Job' right to $($cred.UserName)"
	AddPrivileges $cred.UserName "SeBatchLogonRight"
	
	return $true
}
