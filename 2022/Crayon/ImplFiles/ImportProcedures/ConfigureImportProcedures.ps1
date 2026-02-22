###########################################################################
# Copyright (C) 2015 Flexera Software
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
#

function ConfigureImportProcedures
{
	$key = GetMGSRegKey
	if ($key) {
		$key2 = $key.OpenSubKey("Compliance\CurrentVersion")
		if ($key2) {
			$importXml = $key2.GetValue("ImportXMLDirectory")
			$customImportXml = $key2.GetValue("CustomImportXMLDirectory")
			$key2.Close()
		}
		$key.Close()
	}

	if (!$importXml) {
		Log "" -level "Error"
		Log "ERROR: Could not read value from HKLM\SOFTWARE\ManageSoft Corp\ManageSoft\Compliance\CurrentVersion\ImportXMLDirectory registry entry" -level "Error"

		return $false
	}

	if (!$customImportXml) {
		Log "" -level "Error"
		Log "ERROR: Could not read value from HKLM\SOFTWARE\ManageSoft Corp\ManageSoft\Compliance\CurrentVersion\CustomImportXMLDirectory registry entry" -level "Error"

		return $false
	}

	($importXml, $customImportXml) | %{
		if (!(Test-Path $_ -PathType Container)) {
			New-Item $_ -type Directory | Out-Null
		}
	}

	$importXml = Split-Path $importXml
	$customImportXml = Split-Path $customImportXml

	Log "Overriding product import procedures in '$importXml'"
	$inv = Join-Path $ScriptPath "Inventory"
	if ((Test-Path $inv) -and !(CopyFiles $inv $importXml)) {
		return $false
	}

	Log "Installing custom import procedures to '$customImportXml'"
	$custInv = Join-Path $ScriptPath "CustomInventory"
	if ((Test-Path $custInv) -and !(CopyFiles $custInv $customImportXml)) {
		return $false
	}

	Log "Import procedures installed"

	return $true
}
