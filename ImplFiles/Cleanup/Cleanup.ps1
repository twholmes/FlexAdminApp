###########################################################################
# This script contains various functions to cleanup files and data in
# FlexNet Manager Suite that can become stale and obsolete.
#
# Copyright (C) 2017 Flexera Software
###########################################################################

############################################################
# Helper function for logging a file size nicely

function Format-ByteAmount($byteAmount)
{
	$bytesInKilobyte = 1024;
	$bytesInMegabyte = $bytesInKilobyte * 1024;
	$bytesInGigabyte = $bytesInMegabyte * 1024;

	if ($byteAmount -ge $bytesInGigabyte) {
		return ("{0:0.##}GiB" -f ($byteAmount / $bytesInGigabyte));
	}
	elseif ($byteAmount -ge $bytesInMegabyte) {
		return ("{0:0.##}MiB" -f ($byteAmount / $bytesInMegabyte));
	}
	elseif ($byteAmount -ge $bytesInKilobyte) {
		return ("{0:0.##}KiB" -f ($byteAmount / $bytesInKilobyte));
	}
	else {
		return ("{0}B" -f $byteAmount);
	}
}


############################################################
# Helper function 

function DoCleanupFiles([string]$path, [string]$filter, [int]$ageInDays, [switch]$recurse)
{
	Log ""
	Log "Removing stale files older than $ageInDays days from $path (recursive: $recurse)"
	Log "Filter: $filter"
	
	if (-not (Test-Path -LiteralPath $path)) {
		Log "Path does not exist: $path" -level Warning
		return
	}


	$removed = 0;
	$failures = 0;
	$totalBytes = 0;

	Log "Removing files:"

	Get-ChildItem -LiteralPath $path -recurse:$recurse |
	?{ $file = $_; -not $_.PSIsContainer -and $file.FullName -like $filter -and $file.LastWriteTime -lt (Get-Date).AddDays(-$ageInDays) } | 
	%{
		$file = $_
		$fileName = $file.FullName;

		try {
			Log "`t$fileName"
			Remove-Item -LiteralPath $fileName -ErrorAction Stop

			++$removed;
			$totalBytes += $_.Length;
		} catch {
			++$failures;
			Log "Failed to remove $($fileName): $($_)" -level Warning
		}

		Write-Progress -Activity "Deleting files older than $ageInDays day(s)" -Status "$removed file(s) removed, $failures file(s) skipped, $(Format-ByteAmount $totalBytes) of space freed"
	};

	Write-Progress -Activity "Deleting files older than $ageInDays day(s)" -Status "Complete" -Completed

	Log ""
	Log "Completed: $removed item(s) removed, $failures file(s) skipped, $(Format-ByteAmount $totalBytes) of space freed"
}


############################################################
# Cleanup files that are old and stale in various locations
# that are known to accumulate files over time.
#
# Note: This function is intended to be able to run on any FNMS server.
# The function will delete stale files that are found, regardless of the role of the server.

function CleanupStaleFiles
{
	$beaconDiectory = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\Beacon\CurrentVersion" -name BaseDirectory -ErrorAction Ignore).BaseDirectory
	if ($beaconDirectory) {
		$intermediateData = Join-Path $beaconDirectory "IntermediateData"

		Log "========================================"
		Log "Cleaning up beacon intermediate data"

		DoCleanupFiles $intermediateData -filter "*\RemoteFailures\*.zip" -ageInDays 90 -recurse
		DoCleanupFiles $intermediateData -filter "*\BadPackages\*.zip" -ageInDays 90 -recurse
		DoCleanupFiles $intermediateData -filter "*\Staging\*.zip" -ageInDays 15 -recurse
	}


	Log ""
	Log "========================================"
	Log "Cleaning up incoming bad logs"

	$inc = "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\Reporter\CurrentVersion\IncomingDirectory"
	Get-Item $inc -ErrorAction Ignore |
	Select-Object -ExpandProperty Property |
	%{
		$dir = (Get-ItemProperty $inc -name $_).$_
		if ($dir) {
			DoCleanupFiles $dir -filter "*\BadLogs\*" -ageInDays 60 -recurse
		}
	}


	Log ""
	Log "========================================"
	Log "Cleaning up old logs"

	DoCleanupFiles (Join-Path $env:ProgramData "Flexera Software\Compliance\Logging") -filter "*.log" -ageInDays 90 -recurse
	DoCleanupFiles (Join-Path $env:ProgramData "Flexera Software\Compliance\Logging") -filter "*.log2*-*-*" -ageInDays 90 -recurse
	DoCleanupFiles (GetConfigValue "LogDir") -filter "*.log" -ageInDays 90 -recurse


	Log ""
	Log "========================================"
	Log "Cleaning up old library update files"

	# PURL updates intermittently leave files lying around indefinitely which can be 100s of MB in size
	DoCleanupFiles $env:Temp -filter "*-PURL-*-log.txt" -ageInDays 30
	DoCleanupFiles $env:Temp -filter "*\*-PURL-*\*" -ageInDays 30 -recurse

	return $true
}
