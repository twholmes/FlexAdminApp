###########################################################################
# This script contains various functions to perform Health Checks on
# FlexNet Manager Suite
#
# Copyright (C) 2020 Crayon Australia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
# RunGetIISActiveOperators list Operators accounts that have accessed FNMS in the last 30 days

function RunGetIISActiveOperators
{
  Push-Location "C:\inetpub\logs\LogFiles\W3SVC1"

  $list = Get-ChildItem u_ex*.log |
  Where { ((Get-Date) - $_.LastWriteTime).Days -le 30 } |
  %{ $_.Name } |
  Import-Csv -Delimiter " " -Header ("Date", "Time", "SIP", "Method", "Stem", "Query", "Port", "User", "CIP", "Agent", "Referer", "Status", "SubStatus", "Win32Status", "TimeTaken") |
  Where { $_.Date -notLike "#*" -and $_.User -ne "-" -and $_.User -notLike "*`$" } |
  Select-Object -Property User -Unique

  ForEach ($item in $list)
  {
    Log "Operator = $($item.User)"
  }
  Log ""
  
  #Pop-Location

  Log "Completed RunGetActiveOperators" | Out-Null
  
  return $true
}

###########################################################################
# RunGetIISActiveClients list IP adresses that have accessed FNMS in the last 30 days

function RunGetIISActiveClients
{
  Push-Location "C:\inetpub\logs\LogFiles\W3SVC1"

  $list = Get-ChildItem u_ex*.log |
  Where { ((Get-Date) - $_.LastWriteTime).Days -le 30 } |
  %{ $_.Name } |
  Import-Csv -Delimiter " " -Header ("Date", "Time", "SIP", "Method", "Stem", "Query", "Port", "User", "CIP", "Agent", "Referer", "Status", "SubStatus", "Win32Status", "TimeTaken") |
  Where { $_.Date -notLike "#*" -and $_.User -ne "-" } |
  Select-Object -Property SIP -Unique

  ForEach ($item in $list)
  {
    Log "Client-IP = $($item.SIP)"

    $ulist = Get-ChildItem u_ex*.log |
    Where { ((Get-Date) - $_.LastWriteTime).Days -le 30 } |
    %{ $_.Name } |
    Import-Csv -Delimiter " " -Header ("Date", "Time", "SIP", "Method", "Stem", "Query", "Port", "User", "CIP", "Agent", "Referer", "Status", "SubStatus", "Win32Status", "TimeTaken") |
    Where { $_.Date -notLike "#*" -and $_.SIP -like $item.SIP } |
    Select-Object -Property SIP, Stem, Date, Time, User, Status |   
    Sort-Object -Property Date, Time |
    Select-Object -Property SIP, Stem, Date, Time, User, Status -First 20 
  
    ForEach ($x in $ulist)
    {
      Write-Host "$($x.Date) $($x.Time) $($x.Stem) $($x.User) $($x.Status)"
    }
    Log ""
  }
  Log ""
  
  #Pop-Location

  Log "Completed RunGetActiveOperators" | Out-Null
  
  return $true
}


###########################################################################
# RunSQLCMDScript as current sso user

function RunSQLCMDScript([string]$script, [string]$dbName, [string]$dbServer, [string]$outfilename)
{
  if (!(EnsureSqlModuleLoaded)) {
    return $false
  }

  $logdir = GetConfigValue "LogDir"
  $outfile = Join-Path $logdir $outfilename
  
  try {
    Log ""
    Log "Executing SQL script '$script' with database $dbName on $dbServer"    
    & "C:\Program Files\Microsoft SQL Server\110\Tools\Binn\SQLCMD.EXE" -S $dbServer -d $dbName -E -o $outfile -i $script -v DBName=$dbName
    $raw = Get-Content -Path "d:\Logfiles\sql.out" -RAW
    Write-Host $raw
  }
  catch {
    Log "Error executing SQL script '$script': $_" -level Error
    return $false
  }

  Log "`tSQL script successfully executed"
  return $true
}

###########################################################################
# QueryDatabaseSizes

function QueryDatabaseSizes
{
  $dbserver = GetConfigValue "FNMSDBServer"
  $dbname = GetConfigValue "FNMSComplianceDBName"
  $scriptfile = Join-Path $ScriptPath "QueryDatabaseSizes.sql"

  RunSQLCMDScript $scriptfile $dbname $dbserver "QueryDatabaseSizes.out"  
  
  return $true
}


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
