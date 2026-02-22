###########################################################################
# Copyright (C) 2015-2017 Flexera Software
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

# Common variable used throughout this script

$BaseDataImportDirectory = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\Compliance\CurrentVersion" -name DataImportDirectory -ErrorAction Ignore).DataImportDirectory
if (!$BaseDataImportDirectory) {
	Log "WARNING: Could not obtain Compliance\CurrentVersion\DataImportDirectory registry entry value" -level Warning
}


###########################################################################
# Update original MGSBI configuration file to be executed for a particular task

function BuildMGSBIConfigFile($task, $importName, $uploadFileType, $uniqueImportName, $logFile, $origConfigFile, $builtConfigFile)
{
	$c = [xml](Get-Content $origConfigFile)

	$i = Select-Xml -Xml $c -XPath "/root/Imports/Import[@Name='$importName']"
	if (!$i) {
		Log "WARNING: <Import Name='$importName'> not found in $origConfigFile" -level Warning
	} else {
		# Give the import a unique name so we can look it up later for status reporting
		$i.Node.Name = $uniqueImportName

		# Modify connection string to point to actual data source file
		$dataSourceFilePath = Join-Path (Join-Path $BaseDataImportDirectory $task.DataImportDirectory) $task.DataSourceFileName
		if ($uploadFileType -eq "xml") {
			$cs2 = $dataSourceFilePath
			$i.Node.Type = "XML"
			if ($i.Node.AccountIsEncrypted) {
				$i.Node.AccountIsEncrypted = "False"
			}
		} else {
			$cs2 = $i.Node.ConnectionString -replace "Data Source=([^;]*)", "Data Source=$dataSourceFilePath"

			if ($i.Node.ConnectionString -eq $cs2) {
				Log "WARNING: Pattern to find and update data source in connection string for <Import Name='$importName'> in $origConfigFile did not work" -level Warning
				Log "Connection string is: $($i.Node.ConnectionString)" -level Warning
			}
		}

		# Need to use $cs2.PSObject.BaseObject here to avoid problem described at
		# http://stackoverflow.com/questions/10355578/why-is-powershell-telling-me-a-string-is-not-a-string-and-only-when-calling-str
		$i.Node.ConnectionString = $cs2.PSObject.BaseObject

		# Remove all <Log> elements and insert an element for our run
		if ($i.Node.Log) {
			$i.Node.Log | %{ $i.Node.RemoveChild($_) } | Out-Null
		}

		# Create element: <Log Name="DiagnosticLog" LogLevel="Debug" Output="File" FileName="c:\MyLogFile.log" />
		$l = $c.CreateElement("Log")
		$l.SetAttribute("Name", "DiagnosticLog")
		$l.SetAttribute("LogLevel", "Debug")
		$l.SetAttribute("Output", "File")
		$l.SetAttribute("FileName", $logFile)
		$i.Node.PrependChild($l) | Out-Null

		Log "`tDiagnostic log file for end user download: $logFile"

		# Set signature for the import
		if (!$i.Node.Signature) {
			$i.Node.SetAttribute("Signature", "[USER NAME] ([IMPORT NAME])")
		}
		$i.Node.Signature = $i.Node.Signature `
			-replace "\[USER NAME\]", $task.OperatorLogin `
			-replace "\[IMPORT NAME\]", $importName

		# Set data table name for the import if it is not already set explicitly to avoid using an unpredictable name
		if (!$i.Node.DataTableName) {
			if ($i.Node.UsePhysicalTable -eq "true") {
				$i.Node.SetAttribute("DataTableName", "[dbo].[ECMImport_$importName]")
			} else {
				$i.Node.SetAttribute("DataTableName", "[dbo].[#ECMImport_$importName]")
			}
		}
	}

	$c.Save($builtConfigFile)
}


######################################################################################
# Execute MGSBI to perform the import with details as specified by $task & $importName
#
# If the import fails to be executed then this function calls the
# dbo.CustomBusinessDataUploadCompleteTaskWithFailure stored procedure
# before it completes to record the failure.
#
# Returns $null if import failed to execute successfully, otherwise returns an
# object containing a row from the dbo.BusinessImportLogSummary_MT table summarizing
# the import execution.

function ExecuteSingleDataImport($reg, $task, $importName, $dbServer, $dbName, $primary)
{
	$origConfigFile = Join-Path (Join-Path $BaseDataImportDirectory $task.DataImportDirectory) $reg.BusinessAdapterRegistration.ConfigFile
	$builtConfigFile = Join-Path (Join-Path $BaseDataImportDirectory $task.DataImportDirectory) ([System.IO.Path]::GetFileNameWithoutExtension($reg.BusinessAdapterRegistration.ConfigFile) + ".generated.xml")

	# Build an MGSBI config XML file to execute the import
	try {
		$uniqueImportName = $importName + "-" + [System.Guid]::NewGuid()
		$logFileBase = Join-Path $task.DataImportDirectory ("$importName-$($task.CustomBusinessDataUploadTaskID)_{0}.log" -f (Get-Date -format "yyyyMMdd_HHmmss"))
		$logFileFull = Join-Path $BaseDataImportDirectory $logFileBase

		Log "`tGenerating MGSBI config file from $origConfigFile"
		BuildMGSBIConfigFile $task $importName $reg.BusinessAdapterRegistration.UploadFileType $uniqueImportName $logFileFull $origConfigFile $builtConfigFile
	}
	catch {
		Log "ERROR: Failed to process adapter configuration details" -level Error
		Log $_ -level Error

		Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
			-Query "EXEC dbo.CustomBusinessDataUploadCompleteTaskWithFailure $($task.CustomBusinessDataUploadTaskID), @SummaryMessage = 'Import unable to run due to server configuration error'"

		return $null
	}

	Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
		-Query "EXEC dbo.CustomBusinessDataUploadSetImportDetails $($task.CustomBusinessDataUploadTaskID), @UniqueImportName = '$uniqueImportName', @LogFilePath = '$logFileBase'"

	Log ""
	$args = @("`"/ConfigFile=$builtConfigFile`"", "`"/Import=$uniqueImportName`"", "/OperatorLogin=$($task.OperatorLogin)", "/TenantUID=$($task.TenantUID)")
	$ok = ExecuteMGSBI $args

	$failureSummaryMessage = $null # This is set in following logic if task failure needs to be recorded

	# If any records were rejected then log a failure
	$objectsWithRejections = Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
		-Query "SELECT o.Rejected FROM dbo.BusinessImportLogSummary_MT s JOIN dbo.BusinessImportLogObject_MT o ON o.ImportID = s.ImportID WHERE ImportName = '$uniqueImportName' AND o.TenantID = $($task.TenantID) AND o.Rejected > 0"

	if ($objectsWithRejections.Count -ne 0) {
		Log "Some records were rejected from being imported" -level Warning
		$failureSummaryMessage = "Some uploaded records were rejected"
	}
	elseif ($ok) {
		# MGSBI can return a 0 (success) exit status but still have failed (e.g. if a bad /Import= name has been specified).
		# So we perform a check for BusinessImportLogSummary details here as a further verification step to check the import worked.

		#$summary = Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
		# -Query "SELECT * FROM dbo.BusinessImportLogSummary WHERE ImportName = '$uniqueImportName' AND Status = 1 /* completed */ AND EndDate IS NOT NULL"

		$summary = Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
			-Query "SELECT * FROM dbo.BusinessImportLogSummary_MT WHERE ImportName = '$uniqueImportName' AND TenantID=$($task.TenantID)"  

		if ($summary.Count -eq 0) {
			$ok = $false
			Log "ERROR: No import complete summary status found after import with name $uniqueImportName (maybe MGSBI returned a success exit status but really encountered an error?)" -level Error
		} elseif (($summary.Status -eq 0) -or ($summary.EndDate -eq $null)) {
			Log "Data import completed but failed to update summary status"  
		} else {
			Log "Data import completed successfully"
		}
	}

	# Had an error, but haven't worked out a summary message to log yet: get a reasonable summary message to be reported
	if (!$ok -and !$failureSummaryMessage) {
		if (Test-Path $logFileFull) {
			$failureSummaryMessage = "Inspect diagnostic log for error information"
		} else {
			$failureSummaryMessage = 'Import process completed without generating a log file (possible server configuration error?)'
		}
	}

	if ($failureSummaryMessage) {
		Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
			-Query "EXEC dbo.CustomBusinessDataUploadCompleteTaskWithFailure $($task.CustomBusinessDataUploadTaskID), @SummaryMessage = `$(SummaryMessage)" `
			-Variable @("SummaryMessage='$failureSummaryMessage'")

		return $null
	} else {
		return $summary
	}
}


###########################################################################
# Execute MGSBI to perform the import with details as specified by $task

function ExecuteDataImport($task, $dbServer, $dbName)
{
	$id = GetFNMSInstallDir
	if (!$id) {
		Log "ERROR: Failed to get FlexNet Manager Suite installation directory" -level Error

		Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
			-Query "EXEC dbo.CustomBusinessDataUploadCompleteTaskWithFailure $($task.CustomBusinessDataUploadTaskID), @SummaryMessage = 'Server configuration error: could not find FlexNet Manager Suite installation directory'"

		return $false
	}

	# When this process is run from a scheduled task and $BaseDataImportDirectory is
	# at a UNC file path, PowerShell may fail to access files on the UNC file path
	# with errors like "cannot find path ... because it does not exist" *unless*
	# the current location of the process is a regular filesystem location.
	# At this point we can make no assumptions about our location (e.g. previous
	# invocations of Invoke-Sqlcmd are likely to have set our current location to
	# SQL-related path), so we force ourselves to a regular filesystem location here.
	Set-Location $env:USERPROFILE

	$regFileName = Join-Path (Join-Path $BaseDataImportDirectory $task.DataImportDirectory) "AdapterRegistration.xml"
	Log "`tAdapter registration file: $regFileName"

	try {
		$reg = [xml](Get-Content $regFileName -ErrorAction Stop)

		if (-not $reg.BusinessAdapterRegistration.ImportName) {
			throw "No ImportName specified in adapter registration file"
		}
	}
	catch {
		Log "ERROR: Failed to process adapter configuration details" -level Error
		Log $_ -level Error

		Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
			-Query "EXEC dbo.CustomBusinessDataUploadCompleteTaskWithFailure $($task.CustomBusinessDataUploadTaskID), @SummaryMessage = 'Import unable to run due to server configuration error'"

		return $false
	}

	$importNames = $reg.BusinessAdapterRegistration.ImportName.Split(",")
	Log "`tThe following imports will be processed (in order):"
	$importNames | %{ Log "`t`t$_" }
	Log ""

	# Execute imports in order of listing
	foreach ($importName in $importNames) {
		$result = ExecuteSingleDataImport $reg $task $importName $dbServer $dbName
		if (-not $result) {
			return $false
		}
	}

	# All imports have been completed successfully
	if (($result.Status -eq 0) -or ($result.EndDate -eq $null)) {
		$vars = @("SummaryMessage='Task completion status was not updated'")
	} else {
		$vars = @("SummaryMessage=NULL")
	}

	Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
		-Query "EXEC dbo.CustomBusinessDataUploadCompleteTaskSuccessfully $($task.CustomBusinessDataUploadTaskID), @SummaryMessage = `$(SummaryMessage)" `
		-Variable $vars

	return $true
}


###########################################################################
# Process a single data upload task identified by $task, maintaining
# details about the task's status within the database as the processing
# of the task progresses.

function ProcessSingleDataUploadTask($task, $dbServer, $dbName)
{
	Log ""
	Log "Executing data import task ID $($task.CustomBusinessDataUploadTaskID):"
	Log "`tAdapter: $($task.Adapter)"
	Log "`tBase data import directory: $BaseDataImportDirectory"
	Log "`tData import directory: $($task.DataImportDirectory)"
	Log "`tData source file name: $($task.DataSourceFileName)"
	Log "`tTask start time: $($task.StartTime)"
	Log "`tTask last update time: $($task.LastUpdateTime)"
	Log "`tTenant: $($task.TenantName) ($($task.TenantUID))"
	Log "`tOperator: $($task.OperatorLogin)"
	Log ""

	if (!$task.OperatorLogin -or $task.OperatorLogin.Equals([DBNull]::Value)) {
		Log "WARNING: Operator ID $($task.ComplianceOperatorID) who queued this task has been deleted since task was queued; aborting task" -level Warning

		Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
			-Query "EXEC dbo.CustomBusinessDataUploadCompleteTaskWithFailure $($task.CustomBusinessDataUploadTaskID), @SummaryMessage = 'Operator deleted between task being queueud and task running'"

		return $false
	}

	return ExecuteDataImport $task $dbServer $dbName
}


###########################################################################
# Rotate the flexadmin log file to a new file to contain logging from
# running a particular task, or no task if $task is not specified.
#
# This is helpful to keep log files relatively short and clean with
# our long running process here.

function RotateLog($task)
{
	Log ""

	if ($task) {
		$logFileNamePrefix = ("DataImportBatchProcessing-{0} for {1}" -f $task.Adapter, $task.OperatorLogin) -replace "[:*\\/?`"<>|]", "-" #`"
	} else {
		$logFileNamePrefix = "DataImportBatchProcessing"
	}

	InitialiseLogging (GetConfigValue "LogDir") $logFileNamePrefix
}


###########################################################################
# Check if there are any data upload tasks queued for processing in the
# database, if process them if so.

function ProcessDataImportTasks
{
	if (!(EnsureSqlModuleLoaded)) {
		return $false
	}

	# Must have a file-system based location (not, for example, a SQL location) to open a mutex
	Set-Location $env:USERPROFILE

	# The processing of data upload tasks is very stateful, and won't cope
	# with multiple processes running to process tasks concurrently.
	# A mutex is used here to avoid multiple processing.

	$wasCreated = $false
	$mutex = New-Object System.Threading.Mutex($true, "Global\flexadmin-ProcessDataImportTasks", [ref]$wasCreated)

	try {
		$owned = $mutex.WaitOne(0)
		if (!$owned) {
			Log "" -level Error
			Log "ERROR: Another process is already running to process data upload tasks" -level Error
			Log "" -level Error
		} else {
			return DoProcessDataImportTasks
		}
	}
	catch {
		Log "ERROR: Failed to process data upload tasks" -level Error
		Log $_ -level Error
	}
	finally {
		if ($owned) {
			$mutex.ReleaseMutex()
		}

		$mutex.Close()
	}

	return $false
}

function DoProcessDataImportTasks
{
	$dbServer = GetConfigValue "FNMSDBServer"
	$dbName = GetConfigValue "FNMSComplianceDBName"

	# By this point we know that there is no other process running processing data upload tasks; so
	# ensure the status of tasks in the database reflects that.
	$result = Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName -Query "EXEC dbo.CustomBusinessDataUploadClearInProgressStatuses"

	if ($result[0] -ne 0) {
		Log "WARNING: Reset status of $($result[0]) upload task(s) which had an 'in progress' status with no process running" -level Warning
	}

	$failedTaskCount = 0
	$succeededTaskCount = 0

	while ($true) {
		TouchMonitorProcessTimestampFile

		$task = Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName -Query "EXEC dbo.CustomBusinessDataUploadGetNextTaskToExecute"

		if (!$task) {
			break
		}

		RotateLog $task

		if (!(ProcessSingleDataUploadTask $task $dbServer $dbName)) {
			++$failedTaskCount
		} else {
			++$succeededTaskCount
		}
	}

	if ($succeededTaskCount -gt 0 -or $failedTaskCount -gt 0) {
		RotateLog
	}

	# Generate summary logging showing how many tasks were executed
	if ($succeededTaskCount -gt 0) {
		Log "Processing of $succeededTaskCount task(s) succeeded"
	}

	if ($failedTaskCount -gt 0) {
		Log "ERROR: Processing of $failedTaskCount task(s) failed" -level Error
		Log "" -level Error
		return $false
	}

	if ($succeededTaskCount -eq 0) {
		Log ("No tasks queued for execution ({0})" -f (Get-Date))
	}

	return $true
}


###########################################################################
# Monitor and watch for data upload tasks being queued, and process
# them as they arrive.
#
# This is a long-running method. When it reaches a point of having no
# tasks to process, it will block until there are more tasks to be processed.
# The method never terminates (until its running process terminates).

function MonitorAndProcessDataImportTasks
{
	if (!(EnsureSqlModuleLoaded)) {
		return $false
	}

	# IMPORTANT: The event name here must match the name in the App_Code\BusinessDataUploadsController.cs file
	$eh = New-Object System.Threading.EventWaitHandle($false, [System.Threading.EventResetMode]::AutoReset, "Global\flexadmin-NewDataUploadTaskEvent")

	$loopCount = 0
	while ($true) {
		# Do infrequent activities every now and then
		if ($loopCount % 1000 -eq 0) {
			RotateLog # Rotate log so it doesn't go on too long
			DeleteOldDataImportTasks # Delete tasks after a period of time
		}
		++$loopCount

		ProcessDataImportTasks

		Log "Sleeping for 60 seconds or until new task is signalled" -Level Debug
		$eh.WaitOne(60000)
	}
}


###########################################################################
# Touch a file indicating that the monitor process is running

function TouchMonitorProcessTimestampFile
{
	# IMPORTANT: The filename here must match the name in the  App_Code\BusinessDataUploadsController.cs file
	Get-Date -Format "yyyy-MM-dd HH:mm:ss" >$(Join-Path $BaseDataImportDirectory "MonitorAndProcessDataImportTasks.txt")
}


###########################################################################
# Delete details about a task from the database and filesystem
#
# As of the FNMS 2015 R2 release, this process works OK. However in a future
# release, it is possible that the "FNMP database support task" scheduled
# task may also delete records from the BusinessImportLog* tables according
# to a schedule that is independent of the processing here. If that
# functionality changes, operators will not be able to drill down to see
# detailed information about old imports from the time that records in the
# BusinessImportLog* tables get deleted.
#
# The following tickets are logged, and if either or both of these are fixed
# in a future release then it is likely the FNMS out-of-the-box behavior may
# change as described above:
#
# FNMS-25890: No status information is shown in System Tasks and Data Inputs
# page for direct invocation of business import on FNMS server
#
# FNMS-25891: FNMP Database Support scheduled task does not clean up trace
# records from direct execution of MGSBI on FNMS server

function DeleteDataImportTask($task)
{
	if (!$BaseDataImportDirectory) { # Be careful - because we're deleting data here!
		Log "ERROR: Cannot delete data import task $($task.CustomBusinessDataUploadTaskID) as DataImportDirectory is not known" -level Error
		return $false
	}

	$did = Join-Path $BaseDataImportDirectory $task.DataImportDirectory

	Log "`tDeleting task $($task.CustomBusinessDataUploadTaskID) with files in $did"

	$dbServer = GetConfigValue "FNMSDBServer"
	$dbName = GetConfigValue "FNMSComplianceDBName"

	if (Test-Path -Path $did) {
		# Verify  this directory contains an adapter registration file to do a
		# sanity check that this looks like one of our directories and can be
		# safely deleted.

		$regFileName = Join-Path $did "AdapterRegistration.xml"
		if (Test-Path -Path $regFileName) {
			Remove-Item -Recurse -Force $did
		} else {
			Log "WARNING: Not deleting task directory '$did' as it does not contain an AdapterRegistration.xml file" -level Warning
		}
	}

	Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
		-Query "EXEC dbo.CustomBusinessDataUploadDeleteTask $($task.CustomBusinessDataUploadTaskID)"

	return $true
}


###########################################################################
# Delete data import tasks records in the DB and associated directories
# after a period of time.

function DeleteOldDataImportTasks
{
	if (!(EnsureSqlModuleLoaded)) {
		return $false
	}

	$dbServer = GetConfigValue "FNMSDBServer"
	$dbName = GetConfigValue "FNMSComplianceDBName"

	Log "Checking for old completed tasks to be deleted"
	$ok = $true
	$tasks = Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName -Query "EXEC dbo.CustomBusinessDataUploadGetTasksToDelete"

	$tasks | %{
		$ok = (DeleteDataImportTask $_) -and $ok
	}

	Log "Deleted $($tasks.Count) task(s)"
	return $ok
}
