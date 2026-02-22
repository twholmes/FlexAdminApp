###########################################################################
# Copyright (C) 2020 Crayon Australia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Execute ComplianceReader

function ExecuteComplianceReader([string[]] $arguments)
{
	$id = GetFNMSInstallDir
	if (!$id) {
		Log "Could not identify FlexNet Manager Suite installation directory" -level Error
		return $false
	}
	$exe = Join-Path $id "DotNet\bin\ComplianceReader.exe"

	$ok = ExecuteProcess $exe $arguments
	if (!$ok) {
		Log "ComplianceReader.exe failed" -level Error
		return $false
	}
	return $true
}

###########################################################################
# Run EntitlementAutomation

function RunEntitlementAutomation
{
	Log "Running ComplianceReader for EntitlementAutomation"
	$args = ("-e", "EntitlementAutomation")
	
	$ok = ExecuteComplianceReader $args
	return $ok
}


###########################################################################
# Execute MgsImportRecognition

function ExecuteMgsImportRecognition([string[]] $arguments)
{
	$id = GetFNMSInstallDir
	if (!$id) {
		Log "Could not identify FlexNet Manager Suite installation directory" -level Error
		return $false
	}
	$exe = Join-Path $id "DotNet\bin\MgsImportRecognition.exe"

	$ok = ExecuteProcess $exe $arguments
	if (!$ok) {
		Log "MgsImportRecognition.exe failed" -level Error
		return $false
	}
	return $true
}

