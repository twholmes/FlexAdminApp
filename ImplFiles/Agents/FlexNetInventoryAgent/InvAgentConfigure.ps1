###########################################################################
# Copyright (C) 2020 Crayon Australia
###########################################################################


$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
#

function URLListSplit([string]$settingName)
{
	$result = @()

	foreach ($url in (GetConfigValue $settingName).Split(";")) {
		if (!($url -as [System.URI]).AbsoluteURI) {
			Log "ERROR: Value in URL list '$url' is not a valid URL" -level "Error"
			Log "Please edit the $settingName setting in the fnmpsettings.config file and try again" -level "Error"

			return $false
		}

		$result += $url
	}

	return $result
}


###########################################################################
#

function GenerateBootstrapFailoverSettingsNDC([string]$filename, [string[]]$bootstrapDLs, [string[]]$bootstrapRLs)
{
	&{
		Write-Output @"
Format: 5.1
Application: ManagedDeviceSettings
Title: "Bootstrap Failover Settings"
Version: "1,0,0,0"
UserDomain: public; userSelect; inherit
PackageType: ClientSettings

"@

		for ($i = 0; $i -lt $bootstrapDLs.Length; $i++) {
			$uri = $bootstrapDLs[$i] -as [System.URI]

			Write-Output @"
Registry: set; root = HKLM; key = "SOFTWARE\\ManageSoft Corp\\ManageSoft\\Common\\DownloadSettings\\Bootstrap DL $i"; name = Protocol; value = "$($uri.Scheme)"; type = SZ
Registry: set; root = HKLM; key = "SOFTWARE\\ManageSoft Corp\\ManageSoft\\Common\\DownloadSettings\\Bootstrap DL $i"; name = Directory; value = "$($uri.PathAndQuery)"; type = SZ
Registry: set; root = HKLM; key = "SOFTWARE\\ManageSoft Corp\\ManageSoft\\Common\\DownloadSettings\\Bootstrap DL $i"; name = Host; value = "$($uri.Host)"; type = SZ
Registry: set; root = HKLM; key = "SOFTWARE\\ManageSoft Corp\\ManageSoft\\Common\\DownloadSettings\\Bootstrap DL $i"; name = Port; value = "$($uri.Port)"; type = SZ
Registry: set; root = HKLM; key = "SOFTWARE\\ManageSoft Corp\\ManageSoft\\Common\\DownloadSettings\\Bootstrap DL $i"; name = AutoPriority; value = "True"; type = SZ
"@
		}

		for ($i = 0; $i -lt $bootstrapRLs.Length; $i++) {
			$uri = $bootstrapRLs[$i] -as [System.URI]

			Write-Output @"
Registry: set; root = HKLM; key = "SOFTWARE\\ManageSoft Corp\\ManageSoft\\Common\\UploadSettings\\Bootstrap RL $i"; name = Protocol; value = "$($uri.Scheme)"; type = SZ
Registry: set; root = HKLM; key = "SOFTWARE\\ManageSoft Corp\\ManageSoft\\Common\\UploadSettings\\Bootstrap RL $i"; name = Directory; value = "$($uri.PathAndQuery)"; type = SZ
Registry: set; root = HKLM; key = "SOFTWARE\\ManageSoft Corp\\ManageSoft\\Common\\UploadSettings\\Bootstrap RL $i"; name = Host; value = "$($uri.Host)"; type = SZ
Registry: set; root = HKLM; key = "SOFTWARE\\ManageSoft Corp\\ManageSoft\\Common\\UploadSettings\\Bootstrap RL $i"; name = Port; value = "$($uri.Port)"; type = SZ
Registry: set; root = HKLM; key = "SOFTWARE\\ManageSoft Corp\\ManageSoft\\Common\\UploadSettings\\Bootstrap RL $i"; name = AutoPriority; value = "True"; type = SZ
"@
		}
	} |
	Out-File $filename -Encoding ASCII

	return $true
}


###########################################################################
#

function PrepareWindowsInvAgentInstallers
{
	$configFileSource = $ScriptPath
	$targetRootDir = GetConfigValue "StandaloneInstallersDir"

	$sourcePath = "C:\ProgramData\Flexera Software\Warehouse\Staging\Common\Packages\Flexera\Adoption\*\Rev1.0\FlexNet Inventory Agent\msisource"
	$sourceFolders = Get-Item $sourcePath -ErrorAction SilentlyContinue

	if (!$sourceFolders) {
		Log "ERROR: No Windows FlexNet inventory agent package directories found matching the path '$sourcePath'" -level "Error"
		return $false
	}

	$bootstrapDLs = URLListSplit "InvAgentBootstrapDLs"
	if (!$bootstrapDLs) {
		return $false
	}

	$bootstrapRLs = URLListSplit "InvAgentBootstrapRLs"
	if (!$bootstrapRLs) {
		return $false
	}

	$TransformFileName = "InstallFlexNetInvAgent.mst"

	$commonFiles = (
		(Join-Path $configFileSource (Join-Path "Windows" $TransformFileName)),
		(Join-Path $configFileSource "Bootstrap Machine Schedule.nds"),
		(Join-Path $configFileSource "Bootstrap Failover Settings.osd"),
		(Join-Path $configFileSource "Windows\mgssetup.ini")
	)

	$shell = New-Object -com Shell.Application

	foreach ($sourceFolder in $sourceFolders) {
		$version = $sourceFolder -replace ".*\\Adoption\\(.*)\\Rev1.0\\.*", "`$1"
		$targetDir = Join-Path $targetRootDir "FlexNet Inventory Agent\$version\Windows"

		Log "Preparing Windows FlexNet inventory agent installation package in '$targetDir'"

		Remove-Item (Join-Path $targetDir $platform) -Recurse -Force -ErrorAction SilentlyContinue
		$result = New-Item $targetDir -type Directory -ErrorAction Stop

		if (!(CopyFiles $commonFiles $targetDir)) {
			return $false
		}

		if (!(GenerateBootstrapFailoverSettingsNDC (Join-Path $targetDir "Bootstrap Failover Settings.ndc") $bootstrapDLs $bootstrapRLs)) {
			return $false
		}

		# Files to extract from the agent installer .zip file
		$versionedFiles = (
			(Join-Path $sourceFolder "FlexNet Inventory Agent.msi"),
			(Join-Path $sourceFolder "Data1.cab")
		)
	
		if (!(CopyFiles $versionedFiles $targetDir)) {
			return $false
		}

		Log ""
		Log "`tGenerating .bat script to install FlexNet inventory agent"

		@"
@REM This script contains a command line to install version $version of
@REM the FlexNet inventory agent on a computer running Microsoft Windows.
@REM
@REM The following properties can be added (if appropriate) to the msiexec
@REM command line in order to customize specific details used for the
@REM installation:
@REM 
@REM DEPLOYSERVERURL: Sets beacon download location URL to use for
@REM bootstrapping the inventory agent. For example:
@REM 
@REM DEPLOYSERVERURL=http://alternateds.acme.com/ManageSoftDL
@REM
@REM INSTALLDIR: Sets an alternate installation directory instead of
@REM the default %ProgramFiles%\ManageSoft. For example:
@REM
@REM INSTALLDIR="D:\Program Files\Flexera Software\InventoryAgent"

msiexec /i "%~dp0FlexNet inventory agent.msi" TRANSFORMS="%~dp0$TransformFileName" GENERATEINVENTORY=YES APPLYPOLICY=YES BOOTSTRAPSCHEDULE="Bootstrap Machine Schedule" BOOTSTRAPFAILOVERSETTINGS="Bootstrap Failover Settings" REBOOT=ReallySuppress /l*v "%TEMP%\FlexNet inventory agent-install.log" /qb+
"@ |
		Out-File (Join-Path $targetDir "InstallFlexNetInvAgent.bat") -Encoding ASCII

		Log ""
		Log "`tGenerating .bat script for silent installs of the FlexNet inventory agent"

		@"
@REM This script contains a command line to install version $version of
@REM the FlexNet inventory agent on a computer running Microsoft Windows.
@REM
@REM The following properties can be added (if appropriate) to the msiexec
@REM command line in order to customize specific details used for the
@REM installation:
@REM 
@REM DEPLOYSERVERURL: Sets beacon download location URL to use for
@REM bootstrapping the inventory agent. For example:
@REM 
@REM DEPLOYSERVERURL=http://alternateds.acme.com/ManageSoftDL
@REM
@REM INSTALLDIR: Sets an alternate installation directory instead of
@REM the default %ProgramFiles%\ManageSoft. For example:
@REM
@REM INSTALLDIR="D:\Program Files\Flexera Software\InventoryAgent"

msiexec /i "%~dp0FlexNet inventory agent.msi" TRANSFORMS="%~dp0$TransformFileName" GENERATEINVENTORY=YES APPLYPOLICY=YES BOOTSTRAPSCHEDULE="Bootstrap Machine Schedule" BOOTSTRAPFAILOVERSETTINGS="Bootstrap Failover Settings" REBOOT=ReallySuppress /l*v "%TEMP%\FlexNet inventory agent-install.log" /qn
"@ |
		Out-File (Join-Path $targetDir "SilentInstallFlexNetInvAgent.bat") -Encoding ASCII

		Log ""
		Log "`tGenerating .bat script for silent uninstalls of the FlexNet inventory agent"

		@"
@REM This script contains a command line to install version $version of
@REM the FlexNet inventory agent on a computer running Microsoft Windows.
@REM
@REM The following properties can be added (if appropriate) to the msiexec
@REM command line in order to customize specific details used for the
@REM installation:
@REM 
@REM DEPLOYSERVERURL: Sets beacon download location URL to use for
@REM bootstrapping the inventory agent. For example:
@REM 
@REM DEPLOYSERVERURL=http://alternateds.acme.com/ManageSoftDL
@REM
@REM INSTALLDIR: Sets an alternate installation directory instead of
@REM the default %ProgramFiles%\ManageSoft. For example:
@REM
@REM INSTALLDIR="D:\Program Files\Flexera Software\InventoryAgent"

msiexec /x {7A62397D-66E2-41C4-BFFC-2EBB38D16790} REBOOT=ReallySuppress /l*v "%TEMP%\FlexNet inventory agent-install.log" /qn
"@ |
		Out-File (Join-Path $targetDir "SilentUninstallFlexNetInvAgent.bat") -Encoding ASCII



		Log ""
		Log "FlexNet inventory agent install files for Windows can be found in: $targetDir"
		Log ""
		Log "A command line to install an inventory agent can be found in: InstallFlexNetInvAgent.bat"
		Log ""
	}

	return $true
}


###########################################################################
#

function PrepareUNIXInvAgentInstallers
{
	$configFileSource = $ScriptPath
	$targetRootDir = GetConfigValue "StandaloneInstallersDir"

	$sourcePath = "C:\ProgramData\Flexera Software\Warehouse\Staging\Common\Packages\Flexera\Adoption\*\Rev1.0\ManageSoft for * managed devices"
	$sourceDirs = Get-Item $sourcePath -ErrorAction SilentlyContinue

	if (!$sourceDirs) {
		Log "ERROR: No UNIX FlexNet inventory agent package directories found at '$sourcePath'" -level "Error"
		return $false
	}

	$bootstrapDLs = URLListSplit "InvAgentBootstrapDLs"
	if (!$bootstrapDLs) {
		return $false
	}

	$bootstrapRLs = URLListSplit "InvAgentBootstrapRLs"
	if (!$bootstrapRLs) {
		return $false
	}

	$commonFiles = (
		(Join-Path $configFileSource "Bootstrap Machine Schedule.nds"),
		(Join-Path $configFileSource "Bootstrap Failover Settings.osd"),
		(Join-Path $configFileSource "UNIX\UNIXConfig.ini"),
		(Join-Path $configFileSource "UNIX\flexia-rollout.sh"),
		(Join-Path $configFileSource "UNIX\flexia-setup.sh")
	)

	foreach ($sourceDir in $sourceDirs) {
		$version = $sourceDir -replace ".*\\Adoption\\(.*)\\Rev1.0\\.*", "`$1"
		$platform = $sourceDir -replace ".*\\Rev1.0\\ManageSoft for (.*) managed devices", "`$1"

		$targetDir = Join-Path $targetRootDir "FlexNet Inventory Agent\$version\Non-Windows"

		Log "Preparing $platform FlexNet inventory agent installation package in '$targetDir'"

		if (!(Test-Path $targetDir -PathType Container)) {
			$result = New-Item $targetDir -type Directory -ErrorAction Stop
		}

		if (!(CopyFiles $commonFiles $targetDir)) {
			return $false
		}

    Get-ChildItem (Join-Path $targetDir "*.sh") | ForEach-Object {
      # get the contents and replace line breaks by U+000A
      $contents = [IO.File]::ReadAllText($_) -replace "`r`n?", "`n"
      # create UTF-8 encoding without signature
      $utf8 = New-Object System.Text.UTF8Encoding $false
      # write the text back
      [IO.File]::WriteAllText($_, $contents, $utf8)
		  # log conversion
		  Log "Converted $_ to unix file format"
    }		
		
		if (!(GenerateBootstrapFailoverSettingsNDC (Join-Path $targetDir "Bootstrap Failover Settings.ndc") $bootstrapDLs $bootstrapRLs)) {
			return $false
		}

		$pDir = Join-Path $targetDir $platform
		if (Test-Path $pDir) {
			Remove-Item $pDir -Recurse
		}

		$versionedFiles = (,
			($sourceDir, $platform)
		)

		if (!(CopyFiles $versionedFiles $targetDir)) {
			return $false
		}

		Log ""
		Log "FlexNet inventory agent install files for $platform can be found in: $targetDir"
		Log ""
		Log "Scripts to install an inventory agent can be found in: flexia-rollout.sh and flexia-setup.sh"
		Log ""
	}

	return $true
}
