###########################################################################
# Copyright (C) 2020 Crayon Australia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# DownloadContentLibraries

function DownloadContentLibraries
{
    $id = GetFNMSInstallDir
    if (!$id) {
      Log "Could not identify FlexNet Manager Suite installation directory" -level Error
      return $false
    }

  $exe = "$id\DotNet\bin\MgsImportRecognition.exe"
  $arguments = @("-dl")   

  Log "Downloading content libraries"

  $ok = ExecuteProcess $exe $arguments

  if (!$ok) {
    Log "Failed to download the content libraries" -level Error
    return $false
  }
  return $true
}

###########################################################################
# DownloadContentLibraries

function ClearContentLibraryCache
{
    $id = GetFNMSInstallDir
    if (!$id) {
      Log "Could not identify FlexNet Manager Suite installation directory" -level Error
      return $false
    }

  $exe = "$id\DotNet\bin\MgsImportRecognition.exe"
  $arguments = @("-c")    

  Log "Clearing the content library cache"

  $ok = ExecuteProcess $exe $arguments

  if (!$ok) {
    Log "Failed to clear the content library cache" -level Error
    return $false
  }
  return $true
}


###########################################################################
# ImportContentLibraries

function ImportContentLibraries
{
    $id = GetFNMSInstallDir
    if (!$id) {
      Log "Could not identify FlexNet Manager Suite installation directory" -level Error
      return $false
  }
  
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

  $exe = "$id\DotNet\bin\MgsImportRecognition.exe"
  $arguments = @(
    "-ia", "$dataImportDirectory\Content\ARL\RecognitionAfter82.cab",
    "-is", "$dataImportDirectory\Content\SKU"
  )

  Log "Importing content libraries from the local cache"

  $ok = ExecuteProcess $exe $arguments

  if (!$ok) {
    Log "Failed to import the content libraries" -level Error
    return $false
  }
  return $true
}


###########################################################################
# QueueContentLibraryImport

function QueueContentLibraryImport
{
  $download = GetConfigValue "AutomaticallyDownloadContentLibraries"
    $id = GetFNMSInstallDir
    if (!$id) {
      Log "Could not identify FlexNet Manager Suite installation directory" -level Error
      return $false
    }

  $exe = "$id\DotNet\bin\BatchProcessTask.exe"

  if ($download -eq 'Y') {
    Log "Queuing content library Download and Import"
    $arguments = @("run", "ARLDownload")    
  } else {
    Log "Queuing content library Import"
    $arguments = @("run", "ARLImport")    
  }

  $ok = ExecuteProcess $exe $arguments

  if (!$ok) {
    Log "Failed to queue the batch process task to import content libraries" -level Error
    return $false
  }
  return $true
}