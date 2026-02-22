###########################################################################
# Copyright (C) 2017 Flexera Software
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
#

function CleanCsvHeader([string]$header)
{      
  $newheader = ""
  $myArray = New-Object System.Collections.ArrayList
      
  #header line consists of an array of column names as quoted strings, so first we split them
  $myArray = $header.Split("{,}")
      
  #next we loop through the columns array
  ForEach ($item in $myArray)
  {
    #trim out the quotes
    $item = $item -replace '"',''
        
    #we only want the last part of any compound name where the compoents are seperated by an _
    $words = $item.Split("{_}")
    $last = $($words[-1])
        
    #Log "$item >> $last"
    $newheader = $newheader + "#$last#,"
  }
  $newheader = $newheader -replace '#','"'
  
  #finally, remove the last 1 characters
  $newheader = $newheader -replace ".{1}$"

  return $newheader      
}

###########################################################################
#

function CreateExportFolder([string]$foldername, [string]$style)
{
  # find the exports data directory
	$key = GetMGSRegKey
	if ($key) {
		$key2 = $key.OpenSubKey("Compliance\CurrentVersion")
		if ($key2) {
			$dataExportDirectory = $key2.GetValue("DataExportDirectory")
			$key2.Close()
		}
		$key.Close()
	}
	if (!$dataExportDirectory) {
    $dataExportDirectory = GetConfigValue "FNMSDataExportDir"
	}

  # create folder structure dependant on the ExportFolderStyle switch
  $exportsubfolder = $foldername
  
  if ($style.ToLower() -contains 'dated')
  {
    $exportsubfolder = Join-Path $foldername (Get-Date -format d.M.yyyy)
  }
  Log "ExportSubFolder: $exportsubfolder" -level Debug
  
  # make sure the data folder exists
	$datafolder = Join-Path $dataExportDirectory $exportsubfolder	
  try {
    if (!(Test-Path $datafolder -PathType Container)) {
      New-Item $datafolder -type Directory -ErrorAction Stop | Out-Null
      Log "Created folder to hold exported reports" -level Debug
    }
  }
  catch {
    Log "ERROR: Failed to create directory '$datafolder'" -level "Error"
    Log "" -level "Error"
    $error[0] | Log -level "Error"
  }
  return $datafolder
}

###########################################################################
#

function CreateImportsFolder([string]$foldername, [string]$style)
{
  # find the imports data directory
	$key = GetMGSRegKey
	if ($key) {
		$key2 = $key.OpenSubKey("Compliance\CurrentVersion")
		if ($key2) {
			$dataImportDirectory = $key2.GetValue("DataImportDirectory")
			$key2.Close()
		}
		$key.Close()
	}
	if (!$dataImportDirectory) {
    $dataImportDirectory = GetConfigValue "FNMSDataImportDir"
	}

  # create folder structure dependant on the ExportFolderStyle switch
  $importsubfolder = $foldername
  if ($style.ToLower() -contains 'dated')
  {
    $importsubfolder = Join-Path $foldername (Get-Date -format d.M.yyyy)
  }
  Log "ImportSubFolder: $importsubfolder" -level Debug
  
  # make sure the datareports folder exists
	$datafolder = Join-Path $dataImportDirectory $importsubfolder	
  try {
    if (!(Test-Path $datafolder -PathType Container)) {
      New-Item $datafolder -type Directory -ErrorAction Stop | Out-Null
      Log "Created folder to hold import data" -level Debug
    }
  }
  catch {
    Log "ERROR: Failed to create directory '$datafolder'" -level "Error"
    Log "" -level "Error"
    $error[0] | Log -level "Error"
  }
  return $datafolder
}

###########################################################################
#

function ExportQueryToCSV([string]$tenant, [string]$folder, [string]$folderstyle, [string]$name, [string]$query)
{
  # find the exports data directory
  $exportfolder = CreateExportFolder $folder $folderstyle
	
	# set the export file path
	$filename = $name -replace ' ','_'
	$exportfile = Join-Path $exportfolder ($filename + ".csv")

  # set the database connection
	$dbServer = GetConfigValue "FNMSDBServer"
	$dbName = GetConfigValue "FNMSComplianceDBName"

  # run the report
  Log "Export Report: $name" -level Debug
  Log "Export File: $exportfile" -level Debug
	$ok = $false
  try 
  {
    # trial run of the report query to get the number of records
		$report = @(Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
			-Query $query)

    # only try the export if there are report records available
		if ($report.Count -eq 0) {
			$ok = $false
			Log "ERROR: No reports rows were returned" -level Error
		} 
		else 
		{
		  #run the report query and pass the results to the exporter
		  $report = @(Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName -Query $query) | 		
          Export-CSV -Path $exportfile -Force
    
      #remove first line that contains an unwanted data type marker
      $tempfile = Join-Path $exportfolder ($filename + "-temp.csv")
      get-content $exportfile | select -Skip 1 | set-content "$tempfile"
      move "$tempfile" $exportfile -Force   
      
      #get clean column names from csv header
      $header = (get-content $exportfile -TotalCount 1)
      $newheader = CleanCsvHeader $header
            
      #write the new header, then the report body
      set-content "$tempfile" $newheader
      get-content $exportfile | select -Skip 1 | add-content "$tempfile"
      move "$tempfile" $exportfile -Force
    }
  }
  catch 
  {
    Log "Error Exporting $filename" -level "Error"
  }
}

###########################################################################
#

function ExportQueryToXLSX([string]$tenant, [string]$folder, [string]$folderstyle, [string]$name, [string]$query)
{
  # find the exports data directory
  $exportfolder = CreateExportFolder $folder $folderstyle

	# set the export file path
	$filename = $name -replace ' ','_'
	$exportfile = Join-Path $exportfolder ($filename + ".xlsx")

  # set the database connection
	$dbServer = GetConfigValue "FNMSDBServer"
	$dbName = GetConfigValue "FNMSComplianceDBName"

  # run the report
  Log "Export Report: $name" -level Debug
  Log "Export File: $exportfile" -level Debug
	$ok = $false
  try 
  {
    # trial run of the report query to get the number of records
		$report = @(Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
			-Query $query)

    # only try the export if there are report records available
		if ($report.Count -eq 0) {
			$ok = $false
			Log "ERROR: No reports rows were returned" -level Error
		} else {
		   $report = @(Invoke-Sqlcmd -ServerInstance $dbServer -Database $dbName `
			    -Query $query) | 		
      .\Export-XLSX -Path $exportfile -WorkSheetName $name -Append
    }
  }
  catch 
  {
    Log "Error Testing Export-XLS" -level "Error"
  }
}

