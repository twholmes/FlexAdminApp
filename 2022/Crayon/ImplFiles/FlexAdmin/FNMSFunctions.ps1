###########################################################################
# This script contains various functions available for use in flexadmin
# modules related to the use of FlexNet Manager Suite.
#
# Copyright (C) 2015-2018 Flexera
###########################################################################


############################################################
# Gets the "HKLM\SOFTWARE\ManageSoft Corp\ManageSoft"
# registry key. Returns $null if the key does not exist.
#
# If the returned value is not $null, it should be explicitly closed
# once it is no longer needed. For example:
#
# $key = GetMGSRegKey
# try { ... }
# finally {
#	if ($key) {
#		...
#		$key.Close()
#	}
# }

function GetMGSRegKey
{
	$key = Get-Item "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft" -ErrorAction SilentlyContinue
	if (!$key) {
		$key = Get-Item "HKLM:\SOFTWARE\ManageSoft Corp\ManageSoft" -ErrorAction SilentlyContinue
	}

	return $key
}


###########################################################################
#

function GetFNMSInstallDir
{
	$id = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft" -name ComplianceInstallDir -ErrorAction Ignore).ComplianceInstallDir
	if (-not $id) {
		$id = (Get-ItemProperty "HKLM:\SOFTWARE\ManageSoft Corp\ManageSoft" -name ComplianceInstallDir -ErrorAction Ignore).ComplianceInstallDir
	}
	
	return $id
}


###########################################################################
#

function ExecuteMGSBI([string[]] $arguments)
{
	$id = GetFNMSInstallDir
	if (!$id) {
		Log "Could not identify FlexNet Manager Suite installation directory" -level Error
		return $false
	}

	$mgsbi = Join-Path $id "DotNet\bin\MGSBI.exe"

	$ok = ExecuteProcess $mgsbi $arguments

	if (!$ok) {
		Log "MGSBI.exe failed" -level Error
		return $false
	}

	return $true
}


###########################################################################

function StoreMGSBILogInDB($logFile, $sessionUID, $tenantUID = '0000000000000000')
{
	if (!(Test-Path $logFile.Replace("[", "``[").Replace("]", "``]"))) {
		Log "WARNING: Log file not found: $logFile" -level Warning
		return # No log file created: do nothing
	}

	Log "Storing log file in database: $logFile"

	if (!(EnsureSqlModuleLoaded)) {
		return $false
	}

	[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression") | Out-Null
	[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null

	$zip = [System.IO.Path]::GetTempFileName()
	try {
		$fs = New-Object System.IO.FileStream($zip, "Create")
		try {
			$archive = New-Object System.IO.Compression.ZipArchive($fs, "Create")
			$entry = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $logFile, (Split-Path $logFile -Leaf))
		}
		finally {
			if ($archive) {
				$archive.Dispose()
			}
			$fs.Dispose()
		}
		
		$fileContent = (Get-Content $zip -Encoding Byte | %{ [string]::Format("{0:x2}", $_) }) -Join ""

		$dbServer = GetConfigValue "FNMSDBServer"
		$dbName = GetConfigValue "FNMSComplianceDBName"

		Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
			-Query "
				EXEC dbo.SetTenantUID '`$(TenantUID)'

				INSERT INTO dbo.LogFile(SessionUID, TaskStepID, FileContent, FileExtension)
				SELECT st.SessionUID, ts.TaskStepID, 0x`$(FileContent), '.zip'
				FROM dbo.TaskExecutionStatus st, dbo.TaskStep ts
				WHERE st.SessionUID = '`$(SessionUID)'
					AND ts.TaskStepResourceName = 'TaskStep.Business.ImportData'
			" `
			-Variable ("TenantUID=$tenantUID", "SessionUID=$sessionUID", "FileContent=$fileContent")
	}
	finally {
		Remove-Item $zip -Force
	}
}

