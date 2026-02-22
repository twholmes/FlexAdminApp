###########################################################################
# Copyright (C) 2020 Crayon Australia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Get the Beacon install directory

function GetBeaconInstallDir
{
	$id = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft" -name ETCPInstallDir -ErrorAction Ignore).ETCPInstallDir
	if (-not $id) {
		$id = (Get-ItemProperty "HKLM:\SOFTWARE\ManageSoft Corp\ManageSoft" -name ETCPInstallDir -ErrorAction Ignore).ETCPInstallDir
	}
	return $id
}

###########################################################################
# Execute MgsImportRecognition

function ExecuteInventoryAgent([string[]] $arguments)
{
	$id = GetBeaconInstallDir
	if (!$id) {
		Log "Could not identify Beacon installation directory" -level Error
		return $false
	}
	$exe = Join-Path $id "Tracker\ndtrack.exe"

	$ok = ExecuteProcess $exe $arguments
	if (!$ok) {
		Log "ndtrack.exe failed" -level Error
		return $false
	}
	return $true
}

###########################################################################
# Run Inventory Agent in full UI mode

function RunInventoryAgent
{
	Log "Running Inventory Agent in full UI mode"
	$args = ("-t", "Machine", "-o", "UserInteractionLevel=Full")
	
	$ok = ExecuteInventoryAgent $args
	return $ok
}

###########################################################################
# Execute nddchedag

function ExecuteScheduleAgent([string[]] $arguments)
{
	$id = GetBeaconInstallDir
	if (!$id) {
		Log "Could not identify Beacon installation directory" -level Error
		return $false
	}
	$exe = Join-Path $id "Schedule Agent\ndschedag.exe"

	$ok = ExecuteProcess $exe $arguments
	if (!$ok) {
		Log "ndschedag.exe failed" -level Error
		return $false
	}
	return $true
}

###########################################################################
# Run Schedule Agent in full UI mode

function RunScheduleAgent
{
	Log "Running ScheduleAgent in full UI mode"
	$args = ("-t", "Machine", "-o", "UserInteractionLevel=Full")
	
	$ok = ExecuteScheduleAgent $args
	return $ok
}

