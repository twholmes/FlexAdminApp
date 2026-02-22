###########################################################################
# Copyright (C) 2020 Craton Auastralia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# GENERAL
###########################################################################

###########################################################################
# Set Command Timeout (on SQL connections for import tasks)

function SetCommandTimeout
{
  # get the current setting from the registry
  $key = GetMGSRegKey
  if ($key) {
    $subkey = $key.OpenSubKey("Compliance\CurrentVersion")
    if ($subkey) {
      $commandtimeout = $subkey.GetValue("CommandTimeout")
      $subkey.Close()
    }
    $subkey.Close()
  }
  if (!$commandtimeout) {
    $commandtimeout = 7200
    Log "CommandTimeout not set, defaulting to 7200"
  } else {
    Log "CommandTimeout is currently $commandtimeout" 
  } 
  
  # prompt for a new timeout value  
  $prompt = "Enter a new value for CommandTimeout [default: $commandtimeout]"
  [uint16]$v = Read-Host -prompt $prompt
  if (!$v) {
    [uint16]$v = [convert]::ToUint16($commandtimeout, 10)
  }
  SetConfigValue -settingName "CommandTimeout" -value "$v"
  
  if ($key -and $v) {
    $subkey = $key.OpenSubKey("Compliance\CurrentVersion", $true)
    if ($subkey) {
      $subkey.SetValue("CommandTimeout", $v, [Microsoft.Win32.RegistryValueKind]::DWORD)
      $subkey.Close()
    }
    $subkey.Close()
  }
  return $true
}

###########################################################################
# Set registry to disable Certificate revocation check

function DisableCertificateRevocationCheck
{
  # always prompt for revocation setting
  $switch = PromptForInput "Set registry to disable Certificate revocation check? [Y or N] (default: N)" "N"
  SetConfigValue "DisableCertificateRevocationCheck" $switch

  # get revocation setting
  $switch = GetConfigValue "DisableCertificateRevocationCheck"
  if ($switch -eq "Y") {
    Log "CheckCertificateRevocation is disabled"
  } else {
    Log "CheckCertificateRevocation is enabled (default)"
  }

  # delete the CheckCertificateRevocation entry if it exists
  $key = GetMGSRegKey
  if (!$key) {
    Log "MGSRegKey not found" -level "Error"
    return $false
  } else {
    $subkey = $key.OpenSubKey("Common", $true)
    if (!$subkey) {
      Log "MGSRegKey-Common key does not exist" -level "Error"
      return $false
    }

    $value = $subkey.GetValue("CheckCertificateRevocation")
    if (!$value) {
      Log "CheckCertificateRevocation key is not present"
      if ($switch -eq "Y") {
        $subkey.SetValue("CheckCertificateRevocation", "False", [Microsoft.Win32.RegistryValueKind]::STRING)        
        Log "CheckCertificateRevocation key has been created and set to `"False`""        
      }
    } else {
      Log "CheckCertificateRevocation found ($value)"
      if ($switch -ne "N") {
        $subkey.DeleteValue("CheckCertificateRevocation")        
        Log "CheckCertificateRevocation key has been deleted"           
      }
    }
    $subkey.Close()    
  }
  return $true
}


###########################################################################
# IIS
###########################################################################

###########################################################################
# Stop IIS

function IISStop
{
  Log "Stopping IIS ..." -Level Warning
  IISReset /stop | Out-Null
  Log ""
  return $true
}

###########################################################################
# Start IIS

function IISSart
{
  Log "Starting IIS ..." -Level Warning
  IISReset /start | Out-Null
  Log ""
  return $true
}


###########################################################################
# Batch Processor
###########################################################################

###########################################################################
# Execute BatchProcessTaskConsole

function ExecuteBatchProcessTaskConsole([string[]] $arguments)
{
  $id = GetFNMSInstallDir
  if (!$id) {
    Log "Could not identify FlexNet Manager Suite installation directory" -level Error
    return $false
  }
  $exe = Join-Path $id "DotNet\bin\BatchProcessTaskConsole.exe"

  $ok = ExecuteProcess $exe $arguments
  if (!$ok) {
    Log "BatchProcessTaskConsole.exe failed" -level Error
    return $false
  }
  return $true
}

###########################################################################
# Run BatchProcessor List Tasks

function RunBatchProcessorConsoleListTasks
{
  Log "Running BatchProcessTaskConsole to list tasks"
  #$args = ("-e", "EntitlementAutomation")
  $args = ("list-tasks")  
  
  $ok = ExecuteBatchProcessTaskConsole $args
  return $ok
}

###########################################################################
# Run BatchProcessor Pause Processing

function RunBatchProcessorConsolePauseProcessing
{
  Log "Running BatchProcessTaskConsole to pause processing"
  $args = ("process-dispatch", "-p")
  
  $ok = ExecuteBatchProcessTaskConsole $args
  return $ok
}

###########################################################################
# Run BatchProcessor Resume Processing

function RunBatchProcessorConsoleResumeProcessing
{
  Log "Running BatchProcessTaskConsole to resume processing"
  $args = ("process-dispatch", "-r")
  
  $ok = ExecuteBatchProcessTaskConsole $args
  return $ok
}

