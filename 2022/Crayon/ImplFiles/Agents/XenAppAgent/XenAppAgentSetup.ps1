###########################################################################
# Copyright (C) 2015 Flexera Software
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
#

function PrepareXenAppAgentInstaller
{
	$sourceInstallerDir = Join-Path (GetConfigValue "FNMSDownloadDir") "Installers\Citrix XenApp Server Agent"

	if (!(Test-Path $sourceInstallerDir)) {
		Log "" -level "Error"
		Log "The Inventory Beacon package directory does not exist in the specified location: $sourceInstallerDir" -level "Error"
		Log "" -level "Error"
		return $false
	}
	
	$sourceImplFilesDir = Join-Path $ScriptPath "InstallFiles"
	
	# Destination folder
	$installersDir = GetConfigValue "StandaloneInstallersDir"
	$targetDir = Join-Path $installersDir "XenApp Server Agent"

	Log "Building standalone installer scripts for XenApp Agent in '$targetDir'"
	return PrepareStandaloneInstaller $sourceImplFilesDir $sourceInstallerDir $targetDir
}


###########################################################################
#
	
function PrepareStandaloneInstaller([string] $sourceImplFilesDir, [string] $sourceInstallerDir, [string] $targetDir)
{
	$commonFiles = (
		(Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) "flexadmin.ps1"),
		(Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) "FlexAdmin\FlexAdminFunctions.ps1"),
		(Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) "FlexAdmin\FNMSFunctions.ps1")
	)
	
	# Copy files to target directory
	if (Test-Path $targetDir) {
		Remove-Item $targetDir -recurse
	}

	if (!(Test-Path $targetDir -PathType Container)) {
		$result = New-Item $targetDir -type Directory -ErrorAction Stop
	}

	if (!(CopyFiles "$sourceInstallerDir\*" $targetDir)) {
		return $false
	}

	if (!(CopyFiles "$sourceImplFilesDir\*" $targetDir)) {
		return $false
	}
	
	if (!(CopyFiles $commonFiles $targetDir)) {
		return $false
	}
	
	# Log ""
	# Log "Standalone install files can be found in: $targetDir"
	# Log ""

	return $true
}
