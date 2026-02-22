###########################################################################
# Copyright (C) 2015-2017 Flexera Software
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
#

function InstallDataImportWebPortalAdapters
{
	$id = GetFNMSInstallDir
	if (!$id) {
		Log "" -level Error
		Log "ERROR: Could not determine FlexNet Manager Suite installation directory from HKLM\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\ComplianceInstallDir registry entry" -level Error

		return $false
	}

	# Get the portal install folder
	$webUIDir = Join-Path $id "WebUI"
	$baDir = Join-Path $webUIDir "Adapters"
	$baOldDir = "$($baDir).old"

	Log "Backing up existing installed business adapters"

	if (Test-Path -Path $baOldDir) {
		Remove-Item -Recurse -Force $baOldDir
	}
	if (Test-Path -Path $baDir) {
		# Attempting to use Move-Item tends to give an "access denied" error here due to in use files,
		# but Copy-Item followed by Remove-Item appears to work more reliably (it still sometimes fails, but less frequently)
		#Move-Item -Force $baDir $baOldDir
		Copy-Item $baDir $baOldDir
		Remove-Item -Recurse -Force $baDir
	}

	Log "Installing Data Import Web Portal adapters to '$webUIDir'"
	if (!(CopyFiles (Join-Path $ScriptPath "Adapters") $webUIDir)) {
		return $false
	}

	Log "`tData Import Web Portal adapters installed"

	return $true
}


###########################################################################
#

function ConfigureDataImportWebPortal
{
	$id = GetFNMSInstallDir
	if (!$id) {
		Log "" -level Error
		Log "ERROR: Could not determine FlexNet Manager Suite installation directory from HKLM\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\ComplianceInstallDir registry entry" -level Error

		return $false
	}

	$ok = InstallDataImportWebPortalFiles $id
	
	if ($ok) {
		$ok = PatchDataInputsIndex $id
	}

	if ($ok) {
		$ok = ConfigureWebConfig $id
	}

	return $ok
}


###########################################################################
#

function InstallDataImportWebPortalFiles([string]$installDir)
{
	# Get the portal install folder
	$webUIDir = Join-Path $installDir "WebUI"

	Log "Installing Data Import Web Portal files to '$webUIDir'"
	if (!(CopyFiles ((Join-Path $ScriptPath "WebUI") + "\*") $webUIDir)) {
		return $false
	}

	Log "`tData Import Web Portal files installed"
	return $true
}


###########################################################################
# This function patches the file <InstallDir>\WebUI\Views\DataInputs\Index.cshtml
# to add an "Upload Data" tab.
#
# This is done by finding the following line in the file...
#
#		.Add("Index_BusinessImportData", icon: Icons.MainNavInventory);
#
# ... and adding the following statement at the end of the line:
#
#		tabs.Add("BusinessDataUploads", caption: "Upload Data", icon: Icons.MainNavReportsIndex);

function PatchDataInputsIndex([string]$installDir)
{
	$indexFile = Join-Path $installDir "WebUI\Views\DataInputs\Index.cshtml"
	$origFile = "$indexFile.orig"
	$tempFile = [System.IO.Path]::GetTempFileName()

	Log "Patching Data Inputs page to add 'Upload Data' tab: $indexFile"

	try {
		$foundLine = $false
		$changed = $false

		$fromRegEx = '(.Add\("Index_BusinessImportData", [^;]*;).*'
		$toText = '$1 tabs.Add("BusinessDataUploads", caption: "Upload Data", icon: Icons.MainNavReportsIndex);'

		Get-Content $indexFile | %{
			if ($_ -match $fromRegEx) {
				$foundLine = $true
				$out = $_ -replace $fromRegEx, $toText
				if ($out -ne $_) {
					$changed = $true
				}
				$out
			} else {
				$_
			}
		} >$tempFile

		if (!$foundLine) {
			Log "" -level Error
			Log "ERROR: Unable to find expected code in $indexFile" -level Error
			Log "It is likely that the PatchDataInputsIndex function in the following script requires updating:" -level Error
			Log "$ScriptPath\DataImportWebPortal-Setup.ps1" -level Error

			return $false
		}

		if ($changed) { # Don't touch .cshtml file unless it has actually changed to avoid unnecessary recompiles
			if (!(Test-Path $origFile)) {
				Log "`tOriginal file backed up to $origFile"
				Copy-Item $indexFile $origFile # Backup original file before making any changes
			}

			Log "`tFile has been patched; updating"
			Move-Item $tempFile $indexFile -Force
		} else {
			Log "`tFile already updated"
		}
	}
	finally {
		Remove-Item $tempFile -Force -ErrorAction SilentlyContinue | Out-Null
	}

	return $true
}



###########################################################################
#

function ConfigureWebConfig([string]$installDir)
{
	$webConfig = Join-Path $installDir "WebUI\web.config"
	Log "Checking httpRuntime maxRequestLength in $webConfig"

	$c = [xml](Get-Content $webConfig)

	$i = Select-Xml -Xml $c -XPath "/configuration/system.web/httpRuntime"
	if (!$i) {
		Log "ERROR: /configuration/system.web/httpRuntime element not found in $webConfig" -level Error
		return $false
	}

	Log "`tCurrent maxRequestLength value: $($i.Node.maxRequestLength)"
	# This value must be no smaller than the allowedMaxFileSize configured for uploads in BusinessDataUploads.cs
	$maxUploadSizeInMB = 20
	$maxRequestLength = $maxUploadSizeInMB * 1024 * 1024
	if (!$i.Node.maxRequestLength -or [int]$i.Node.maxRequestLength -lt $maxRequestLength) {
		Log "`tUpdating maxRequestLength to $($maxUploadSizeInMB)MB"
		$i.Node.SetAttribute("maxRequestLength", $maxUploadSizeInMB * 1024 * 1024)
		$c.Save($webConfig)
	} else {
		Log "`tValue is large enough; no need to update"
	}
	
	return $true
}


###########################################################################
#

###########################################################################
#

function ConfigureExcelDriversForSpreadsheetImports
{
	Log "Configuring drivers for Excel 2013 spreadsheets"
	$key = "HKLM:\SOFTWARE\Microsoft\Office\15.0\Access Connectivity Engine\Engines\Excel"
	if ((Configure-ExcelDrivers $key) -eq $false)
	{
  	Log "Configuring drivers for Excel 2010 spreadsheets"
  	$key = "HKLM:\SOFTWARE\Microsoft\Office\14.0\Access Connectivity Engine\Engines\Excel"
  	if ((Configure-ExcelDrivers $key) -eq $false)
  	{
  		Log "" -level "Error"
  		Log "ERROR: Could not configure drivers for Excel 2010 spreadsheets by configuring values under $key" -level "Error"
	  	Log "Check that the 'Microsoft Access Database Engine 2010 Redistributable (32 bit)' components are installed" -level "Error"
	  	Log "These can be downloaded from: https://www.microsoft.com/en-us/download/details.aspx?id=13255" -level "Error"

	  	return $false
	  }
	  Log "`tDrivers for Excel 2010 spreadsheets configured"

	  Log "Configuring drivers for Excel 2003 spreadsheets"
	  $key = "HKLM:\SOFTWARE\Microsoft\Jet\4.0\Engines\Excel"
	  if ((Configure-ExcelDrivers $key) -eq $false)
	  {
  		Log "" -level "Error"
	  	Log "ERROR: Could not configure drivers for Excel 2003 spreadsheets by configuring values under $key" -level "Error"

		  return $false
	  }
	  Log "`tDrivers for Excel 2003 spreadsheets configured"
	  return $true
	}
	Log "`tDrivers for Excel 2013 spreadsheets configured"	
	
	return $true
}


###########################################################################
# This function configures Microsoft Excel drivers with settings
# to reliably read data from Excel spreadsheets while running business adapters.

function Configure-ExcelDrivers([string]$key)
{
	$wow64key = $key -replace "HKLM:\\SOFTWARE\\", "HKLM:\SOFTWARE\Wow6432Node\"

	if ((Test-Path $wow64key))
	{
		$key = $wow64key
	}
	elseif (!(Test-Path $key))
	{
		return $false
	}

	# Do not scan any rows of data to guess column data types
	Set-ItemProperty -path $key -name "TypeGuessRows" -Value 0 -Type "DWORD"

	# Import all columns as text
	Set-ItemProperty -path $key -name "ImportMixedTypes" -Value "Text"
}
