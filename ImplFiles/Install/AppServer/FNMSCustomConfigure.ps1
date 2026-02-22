###########################################################################
# Copyright (C) 2015-2018 Flexera Software
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
# 

function ConfigureFileShares
{

	$key = GetMGSRegKey
	if (!$key)
	{
		Log "ERROR: Failed to open 'ManageSoft' registry key" -level Error
		return $false
	}

	try {
		$dataImportDirectory = (Get-ItemProperty -Path "$($key.PSPath)\Compliance\CurrentVersion" -Name "DataImportDirectory" -ErrorAction Stop).DataImportDirectory 
	}
	catch {
		Log "Error getting registry values: $_" -level Error
		return $false
	}
	$dataImportDirectory = $dataImportDirectory.Trimend("\ ")

	if (!(Test-Path $dataImportDirectory)) {
		New-Item -Path $dataImportDirectory -ItemType Directory | Out-Null
	}
	
	# Create the share
	$dataImportShare = "DataImport"	
	if ($dataImportDirectory) {
		if (!(CreateFileShare $dataImportDirectory $dataImportShare)) {
			return $false
		}
	}

	# Grant access to the share
	$principals = (
		(GetConfigValue "FNMSServiceAccount"),(GetConfigValue "FNMSAdminsGroup"))

	$principals | % {
			# This is not available on Windows 2008 R2
			$ok = GrantShareAccess $dataImportShare $_
			if (!($ok)) {
				return $false
			}

			$ok = GrantFolderAccess $dataImportDirectory $_
			if (!($ok)) {
				return $false
			}
		}

	return $true
}

###########################################################################
# 

function DisableRecognitionDataImportScheduledTask
{
	$recognitionImportTaskName = "FlexNet Manager Platform\Recognition data import"

	$ok = DisableScheduledTask $recognitionImportTaskName
	if (!$ok) {
		return $false
	}

	return $true
}

