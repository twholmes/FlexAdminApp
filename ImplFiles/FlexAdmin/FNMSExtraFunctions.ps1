

###########################################################################
#

function CreateFileShare ([string]$Foldername, [string]$Sharename) {
	$Foldername = $folderName.Trimend("\ ")

	if (!(Test-Path $Foldername)) {
		Log "The folder $Foldername does not exist." -level "Error"
		return $false
	}
		
	$Shares=[WmiClass]"WIN32_Share"

	If (!(Get-WmiObject Win32_Share -filter "name='$Sharename'")) { 
		Log "Creating the '$Sharename' file share on the folder '$Foldername'."
		try {
			$Shares.Create($Foldername,$Sharename,0) | Out-Null

			# Remove default access to everyone
			Revoke-SmbShareAccess -name $Sharename -AccountName Everyone -Force -ErrorAction Stop | Out-Null

		} catch {
			Log "Failed to create the '$Sharename' file share on the folder '$Foldername': $_" -level "Error"
			return $false
		}
		
		#Revisit: The above call doesn't seem to throw any exceptions if it fails to create the share.  
		#		 Need to investigate options for ensuring that exceptions are detected.
		#		 The scripting below is a workaround to ensure that the function does not continue
		#		 if the file share is not created.
		If (!(Get-WmiObject Win32_Share -filter "name='$Sharename'")) { 
			Log "Failed to create the '$Sharename' file share on the folder '$Foldername'." -level "Error"
			return $false
		}
	}
	
	return $true
}

###########################################################################
#

function GrantShareAccess([string]$Sharename, [string] $Principal)
{
	try {
		Log "Granting permission to '$Principal' to access the '$Sharename' file share."
		Grant-SmbShareAccess -name $Sharename -AccountName $Principal -AccessRight Full -Force -ErrorAction Stop | Out-Null
	} catch {
		Log "Failed to grant permission to '$Principal' to access the '$Sharename' file share: $_" -level "Error"
		return $false
	}	

	return $true
}


###########################################################################
#

function GrantFolderAccess([string]$Foldername, [string] $Principal)
{
	$Foldername = $folderName.Trimend("\ ")

	if (!(Test-Path $Foldername)) {
		Log "The folder $Foldername does not exist." -level "Error"
		return $false
	}
	
	try {
		Log "Granting permission to '$Principal' to access the '$Foldername' folder."
		$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($Principal,"FullControl","ContainerInherit,ObjectInherit","None","Allow")
		$ACL = (Get-item $Foldername).getaccesscontrol("Access") 
		$ACL.SetAccessRule($AccessRule) | Out-Null
		Set-Acl $Foldername -AclObject $acl -ErrorAction Stop | Out-Null
	} catch {
		Log "Failed to grant permission to '$Principal' to access the '$Foldername' folder: $_" -level "Error"
		return $false
	}	

	return $true
}


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

############################################################
# Queue a batch process task for a single tenant

function QueueTenantBatchProcessTask([string]$taskName, [string[]]$taskArgs = @(), [boolean]$wait = $false, [string]$tenantUID)
{
	$id = GetFNMSInstallDir
	if (!$id) {
		Log "ERROR: Could not determine FlexNet Manager Platform installation directory" -level Error
		return $false
	}

	$batchProcessTask = Join-Path $id "DotNet\bin\BatchProcessTaskConsole.exe"

	$quotedExe = $batchProcessTask -replace "(.* .*)", "`"`$1`""
	Log "Running the command: $quotedExe run $taskName -t $tenantUID -- $taskArgs"

	$output = & $batchProcessTask run $taskName -t $tenantUID -- $taskArgs 2>&1
	$result = $?

	if (!$result) {
		Log "ERROR: The command failed, returning exit code $result.  See the messages above for further details."  -Level Error
		return $false
	}

	$taskGUID = ""
	$output | % {
		Log $_
		if ($_ -match "Queuing.*task \([A-Za-z0-9]{8}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{12}\)")
		{
			$taskGUID = $_ -replace "Queuing.*task \(([A-Za-z0-9]{8}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}-[A-Za-z0-9]{12})\)", '$1'
		}
	}

	if ($taskGUID -eq "") {
		Log "ERROR: BatchProcessTaskConsole.exe did not return an identifiable UID for this task. Check the output of the command line above for further details." -Level Error
		return $false
	}

	Log "Successfully submitted the batch process task.  MessageID: $taskGUID"

	if (!$wait) {
		return $true
	}

	$dbServer = GetConfigValue "FNMSDBServer"
	$dbName = GetConfigValue "FNMSComplianceDBName"

	Log "Waiting for the task to complete.  This may take a long time."
	$StartTime=(GET-DATE)
	$currentStatus = ""
	while ($true)
	{
		$CurrentTime=(GET-DATE)
		$elapsedTime = (NEW-TIMESPAN -Start $StartTime -End $CurrentTime).TotalSeconds

		try {
			$task = Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName -Query "SELECT * FROM BatchProcessExecutionInfo WHERE Messageid = `'$taskGUID`'" -ErrorAction Stop
		} catch {
			Log "ERROR: Failed to read the task information from the $dbName database on the $dbServer server: $_" -Level Error
			return $false
		}

		if ($task) {
			if ($currentStatus -ne $task.Status) {
				$currentStatus = $task.Status
				Log "Current task status: $currentStatus"		
			}
		}

		switch ($currentStatus) {
			"" { 
				if ($ElapsedTime -ge 30) {
					Log "ERROR: Timeout while waiting for the task to be picked up by the batch process scheduler.   Check to see if the FlexNet Manager Suite Batch Process Scheduler service is running." -Level Error
					return $false
				}
				Start-Sleep -Seconds 5
			}
			"Duplicate" { 
				Log "There is already another task of this type that has been submitted so this task will not be run."
				Log "Task summary: MessageID: $($task.MesageID), TypeName: $($task.TypeName), Status: $($task.Status), Submitted: $($task.Submitted), StartTime $($task.StartTime), FinishTime $($task.FinishTime)"
				return $true
				}
			"Error" { 
				Log "The task failed to complete successfully." -Level Error
				Log "Task summary: MessageID: $($task.MesageID), TypeName: $($task.TypeName), Status: $($task.Status), Submitted: $($task.Submitted), StartTime $($task.StartTime), FinishTime $($task.FinishTime)"
				return $false
				}
			"Success" { 
				Log "The task completed successfully."
				Log "Task summary: MessageID=$($task.MessageID), TypeName=$($task.TypeName), Status=$($task.Status), Submitted=$($task.Submitted), StartTime=$($task.StartTime), FinishTime=$($task.FinishTime)"
				return $true
				}
			default {
				if ($ElapsedTime -ge 43200) { # Wait 12 hours for the task to complete
					Log "ERROR: Timeout while waiting for the task to complete.  Check to see if there is a backlog in the batch process scheduler using the command BatchProcessTaskConsole.exe list-tasks." -Level Error
					return $false
				}
				Start-Sleep -Seconds 60
			}
		}
	}

	return $true
}

###########################################################################
# Disable scheduled task

function DisableScheduledTask ([string] $taskName)
{
  $args = (
    "/change",
    "/disable",
    "/tn", "`"$taskName`""
  )

  $ok = ExecuteProcess "schtasks.exe" $args

  if (!$ok) {
    Log ""
    Log "ERROR: Failed to disable scheduled task '$taskName'"
    return $false
  }

  Log "Successfully disabled the scheduled task $taskName"
  Log ""

  return $true
}

###########################################################################
# Enable scheduled task

function EnableScheduledTask ([string] $taskName)
{
  $args = (
    "/change",
    "/enable",
    "/tn", "`"$taskName`""
  )

  $ok = ExecuteProcess "schtasks.exe" $args

  if (!$ok) {
    Log ""
    Log "ERROR: Failed to disable scheduled task '$taskName'"
    return $false
  }

  Log "Successfully enabled the scheduled task $taskName"
  Log ""

  return $true
}
