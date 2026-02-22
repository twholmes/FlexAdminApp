###########################################################################
# Copyright (C) 2019-2020 Crayon Australia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
# ConfigureAdapterSettings

function ConfigureAdapterSettings()
{
  Log "Configuring the settings for the AD Devices adapter"

  # Force the preferences to be loaded so that the caller will be prompted
  # if the config value is not already set
  $logdir = GetConfigValue "LogDir"  
  $dbserver = GetConfigValue "BeaconStagingDBServer"
  $dbname = GetConfigValue "BeaconStagingDBName"

  # Pre-load preferences for this module
  $adServer = GetConfigValue "DevicesDomainServer"

  $dataFolder = GetConfigValue "DataImportFolder"  
  $filename = GetConfigValue "DevicesDataCsvFile"
    
  return $true
}

###########################################################################
# GenerateMGSBIXML

function GenerateMGSBIXML([string]$source, [string]$dest)
{
  Log "Generating '$dest' from template '$source'"
  try 
  {
    $logdir = GetConfigValue "LogDir"  
    $dbserver = GetConfigValue "BeaconStagingDBServer"
    $dbname = GetConfigValue "BeaconStagingDBName"

    Get-Content $source |
    %{ $_ -replace "{LOGDIR}", $logdir } |
    %{ $_ -replace "{SQLSERVER}", $dbserver } |
    %{ $_ -replace "{DBNAME}", $dbname } |  
    Out-File $dest -Encoding UTF8
  }
  catch 
  {
    Log "Error generating file: $_" -level "Error"
    return $false
  }
  return $true
}

###########################################################################
# Install

function Install
{
  $beaconBaseDirectory = Get-ItemProperty -path "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft\Beacon\CurrentVersion" -name "BaseDirectory" 
  if (!($beaconBaseDirectory = "")) 
  {
    $beaconBaseDirectory = Join-Path $env:ProgramData "Flexera Software\Beacon"  
  }
  $beaconBusinessAdapterDirectory = Join-Path $beaconBaseDirectory "BusinessAdapter"

  if (!(Test-Path $beaconBusinessAdapterDirectory -PathType Container)) 
  {
    Log "" -level Error
    Log "ERROR: The business adapter folder '$beaconBusinessAdapterDirectory' does not exist on this server. Verify that the beacon software is installed." -level Error
    return $false
  }

  $source = Join-Path $ScriptPath "MGSBI.template.xml"
  $dest = Join-Path $beaconBusinessAdapterDirectory "ADDevices.xml"
  if (!(GenerateMGSBIXML $source $dest)) 
  {
    return $false
  }
  return $true
}

###########################################################################
# GetCanonicalName 

function GetCanonicalName ([string]$dn) 
{    
  $d = $dn.Split(',') ## Split the dn string up into it's constituent parts 
  $arr = (@(($d | Where-Object { $_ -notmatch 'DC=' }) | ForEach-Object { $_.Substring(3) }))  ## get parts excluding the parts relevant to the FQDN and trim off the dn syntax 
  [array]::Reverse($arr)  ## Flip the order of the array. 
 
  ## Create and return the string representation in canonical name format of the supplied DN 
  "{0}/{1}" -f  (($d | Where-Object { $_ -match 'dc=' } | ForEach-Object { $_.Replace('DC=','') }) -join '.'), ($arr -join '/') 
}

###########################################################################
# GetCorporateUnit 

Function GetCorporateUnit 
{
  Param ($cn)
  $o = $cn.Split('/')
  if ($o.Length -ge 2) 
  {
    if (($o[1] -eq 'xxx') -or ($o[1] -eq 'zzz')) 
    {
      return $o[1]
    }
  } 
  return 'Bank of Queensland';
}

###########################################################################
# GetLocation

Function GetLocation 
{
  Param ($cn)
  $o = $cn.Split('/')
  if ($o.Length -ge 4) 
  {
    if (($o[1] -eq 'xxx') -or ($o[1] -eq 'zzz')) 
    {
      $o = $o[2..3];
    } 
    else
    {
      $o = $o[1..2]
    }
    if (($o[0].Length -eq 2) -and ($o[1].Length -eq 3)) 
    {
      return "$($o -join '/')"
    }
  } 
  return '';
}


###########################################################################
# ExportADDevicesDataToCSV

function ExportADDevicesDataToCSV([string]$FQDN, [string]$DC)
{
  try 
  {
    $FQDNArray = $FQDN.split(".")
  
    # add a separator of ','
    $Separator = ","

    # search domain must be in Distinguished Name  form. eg. "OU=Servers,DC=flexdemo,DC=com" 
    # so, for each item in the FQDN array
    # .. for (CreateVar; Condition; RepeatAction)
    # .. for ($x is now equal to 0; while $x is less than total array length; add 1 to X
    for ($x = 0; $x -lt $FQDNArray.Length ; $x++)
    { 
      # if it's the last item in the array don't append a ','
      if ($x -eq ($FQDNArray.Length - 1)) { $Separator = "" }
    
      # append to $DN DC= plus the array item with a separator after
      [string]$DN += "DC=" + $FQDNArray[$x] + $Separator
    
      # continue to next item in the array
    }

    # check that the export folder exists (use same folder for import and export)
    $exportFilename = GetConfigValue "DevicesDataCsvFile"
    $dataExportFolder = GetConfigValue "DataImportFolder"    
    if (!(Test-Path $dataExportFolder)) 
    {
      New-Item -path $dataExportFolder -ItemType Directory | Out-Null
    }
    $dataExportFile = Join-Path $dataExportFolder $exportFilename

    # set path for logging
    $csvdeLogFile = Join-Path $dataExportFolder "csv.log"
 
    # set the current date to record export datetime
    $exportDate = get-date -Format 'yyyyMMdd'

    # CredentialManagerTarget has been supplied so check for credentials
    if ((StoredCredentialsExist $FQDN)) 
    {
      #$cred = GetStoredPsCredential $FQDN # -showPassword    
      $cred = GetStoredCredential $FQDN
      $creddomain = $cred.UserName.Split("\")[0]
      $creduser = $cred.UserName.Split("\")[1]      
    }
    else
    {
      Log "Stored credentials for domain $FQDN not found"
      Write-Host ""      
      return $false
    }

    # Update export file name for this doamin    
    $dataExportFile = $dataExportFile.Replace(".csv",".$FQDN.csv")

    Log "Update ADDevices records in Staging database for the domain: $DN"       
    Log "  using $csvde -file `"$dataExportFile`" -s `"$DC`" -r `"objectClass=computer`" -d `"$DN`" -b `"$($creduser)`" `"$($creddomain)`" `"$($cred.CredentialBlob)`""
    Write-Host ""
    
    $csvde = "$($env:systemroot)\system32\csvde.exe"
    & "$csvde" -file "$dataExportFile" -v -j $dataExportFolder -s $DC -r "objectClass=computer" -d "$DN" -b "$($creduser)" "$($creddomain)" "$($cred.CredentialBlob)"    

    # Write out the csvde log file (diagnostic)
    #Get-Content $csvdeLogFile | foreach { Write-Host $_ }

    Write-Host ""
  }
  catch 
  {
    Log "ERRROR: Failed to read AD Devices source data.  Details: $_" -Level Error
    return $false
  }
  return $true
}

###########################################################################
# ImportADDevicesFromCSV

function ImportADDevicesFromCSV([string]$FQDN)
{
  try 
  {
    $FQDNArray = $FQDN.split(".")
  
    # add a separator of ','
    $Separator = ","

    # search domain must be in Distinguished Name  form. eg. "OU=Servers,DC=flexdemo,DC=com" 
    # so, for each item in the FQDN array
    # .. for (CreateVar; Condition; RepeatAction)
    # .. for ($x is now equal to 0; while $x is less than total array length; add 1 to X
    for ($x = 0; $x -lt $FQDNArray.Length ; $x++)
    { 
      # if it's the last item in the array don't append a ','
      if ($x -eq ($FQDNArray.Length - 1)) { $Separator = "" }
    
      # append to $DN DC= plus the array item with a separator after
      [string]$DN += "DC=" + $FQDNArray[$x] + $Separator
    
      # continue to next item in the array
    }

    # check that the import file exists (use same folder for import and export)
    $importFilename = GetConfigValue "DevicesDataCsvFile"        
    $dataImportFolder = GetConfigValue "DataImportFolder"    
    $dataImportFile = Join-Path $dataImportFolder $importFilename
    
    # Update import file name for this domain
    $dataImportFile = $dataImportFile.Replace(".csv",".$FQDN.csv")
    if (!(Test-Path $dataImportFile)) 
    {
      Log "Cannot find import file $dataImportFile"
      Write-Host ""      
      return $false
    }

    # set the current date to record import datetime
    $importDate = get-date -Format 'yyyyMMdd'

    Log "Clear old ADDevices records from Staging database for domain = $FQDN"
    $ClearOldResults = "DELETE FROM [Staging].[dbo].[ADDevices] WHERE [Domain] like '$FQDN'"

    # Call the invoke-sqlcmdlet to execute the insert query
    Invoke-sqlcmd -ServerInstance "localhost" -Database "Staging" -Query $ClearOldResults
       
    Log "Update ADDevices records in Staging database for the domain: $DN"       
    Log "  using exported data in the CSV file $dataImportFile"
    Write-Host ""    
    
    $userRecords = Import-CSV $dataImportFile |
    ForEach-Object {
      $n = $n + 1
      
      $objectclass = $($_.objectClass)  
      $computername = $($_.name)
      
      $DN = $($_.DN)
      $cn = GetCanonicalName $DN
      $domain = $($cn.Split('/')[0])
      
      $os = $($_.operatingSystem)      
      $osv = $($_.operatingSystemVersion)      
      
      $location = $(GetLocation $cn)
      $bu = $(GetCorporateUnit $cn)
      
      $LastLogonTimeStamp = ([datetime]::FromFileTime($_.lastLogonTimestamp).ToString('g'))
      
      Write-Host "." -NoNewLine
      #Write-Host "$computername, $domain, $cn, $LastLogonTimeStamp"
 
      $InsertResults = @"
        INSERT INTO [Staging].[dbo].[ADDevices](ComputerName,Domain,ExportDate,LastLogon,OperatingSystem,OperatingSystemVersion,Location,BusinessUnit,CanonicalName)
        VALUES ('$computername','$domain','$importDate','$LastLogonTimeStamp','$os','$osv','$location','$bu','$cn')
"@     
      #call the invoke-sqlcmdlet to execute the insert query
      Invoke-sqlcmd -ServerInstance "localhost" -Database "Staging" -Query $InsertResults
    }
    Write-Host " ($($n-1) records written)"
    Write-Host ""    
  }
  catch 
  {
    Log "ERRROR: Failed to import AD Devices source data.  Details: $_" -Level Error
    return $false
  }
  return $true
}

###########################################################################
# Process import for the configured domain set

function ProcessDomainsForADDevices
{
  Log ""
  Log "Processing domains for AD Devices:"

  #Get-Command -module sqlserver

  $dbserver = GetConfigValue "BeaconStagingDBServer"
  $dbname = GetConfigValue "BeaconStagingDBName"

  # loop through the configured set of domains
  Read-SqlTableData -ServerInstance $dbserver -DatabaseName $dbname -SchemaName "dbo" -TableName "ADDomains" -TopN 3 |
  ForEach-Object {
    $n = 1
    $flat = $($_.Domain)
    $fqdn = ($_.FQDN)
    $server = ($_.DomainServer)    
    try 
    {
      Log "... process ADDevices for domain #$n = $flat"
      ExportADDevicesDataToCSV $fqdn $server | Out-Null  
      ImportADDevicesFromCSV $fqdn | Out-Null
      $n = $n + 1
    }
    catch 
    {
      Log "ERROR: Failed to process imports for domain '$flat'" -level "Error"
      Log "" -level "Error"
      $error[0] | Log -level "Error"
      return $false
    }
  }
  Log ""  

  return $true
}


###########################################################################
###########################################################################
# POWERSHELL NATIVE AD EXPORT ROUTINES

###########################################################################
# WriteADDevicesToStaging

function WriteADDevicesToToStaging([string]$FQDN, [string]$DC)
{
  try 
  {
    $FQDNArray = $FQDN.split(".")
	
  	# add a separator of ','
	  $Separator = ","

    # search domain must be in Distinguished Name  form. eg. "OU=Servers,DC=flexdemo,DC=com" 
	  # so, for each item in the FQDN array
	  # .. for (CreateVar; Condition; RepeatAction)
	  # .. for ($x is now equal to 0; while $x is less than total array length; add 1 to X
	  for ($x = 0; $x -lt $FQDNArray.Length ; $x++)
		{ 
		  # if it's the last item in the array don't append a ','
		  if ($x -eq ($FQDNArray.Length - 1)) { $Separator = "" }
		
		  # append to $DN DC= plus the array item with a separator after
		  [string]$DN += "DC=" + $FQDNArray[$x] + $Separator
		
	  	# continue to next item in the array
		}

    # set the current date to record export datetime
    $exportDate = get-date -Format 'yyyyMMdd'

    # CredentialManagerTarget has been supplied so check for credentials
    if ((StoredCredentialsExist $FQDN)) 
    {
      $cred = GetStoredPsCredential $FQDN # -showPassword
    }
    else
    {
      Log "Sored credentials for domain $FQDN not found"
      return $false
    }

    Log "Clear old ADDevices records from Staging database for domain = $FQDN"
    $ClearOldResults = "DELETE FROM [Staging].[dbo].[ADDevices] WHERE [Domain] like '$FQDN'"

    #call the invoke-sqlcmdlet to execute the insert query
    Invoke-sqlcmd -ServerInstance "localhost" -Database "Staging" -Query $ClearOldResults
       
    Log "Update ADDevices records in Staging database" 
    
    $array = Get-AdComputer -SearchBase $DN -Server $FQDN -Credential $cred -Filter * -properties canonicalname,cn | 
    ForEach-Object {
      $computername = $($_.cn)    
      $domain = $($_.CanonicalName.Split('/')[0])    
      $exportedate = $($_.ExportDate)
      $LastLogonTimeStamp = ([datetime]::FromFileTime($_.lastLogonTimestamp).ToString('g'))      
      $location = $(GetLocation $_.CanonicalName)
      $bu = $(GetCorporateUnit $_.CanonicalName)
      Write-Host "$computername, $domain"
      
      $InsertResults = @"
        INSERT INTO [Staging].[dbo].[ADDevices](ComputerName,Domain,ExportDate,LastLogon,OperatingSystem,OperatingSystemVersion,Location,BusinessUnit,CanonicalName)
        VALUES ('$computername','$domain','$importDate','$LastLogonTimeStamp','$os','$osv','$location','$bu','$cn')
"@     
      #call the invoke-sqlcmdlet to execute the insert query
      Invoke-sqlcmd -ServerInstance "localhost" -Database "Staging" -Query $InsertResults
    }
    Write-Host ""
  }
  catch 
  {
    Log "ERRROR: Failed to read AD Devices source data.  Details: $_" -Level Error
    return $false
  }
  return $true
}


###########################################################################
###########################################################################
# TEST ROUTINES

###########################################################################
# ExportADDevicesData (test routine)

function ExportADDevicesData
{
  # get reader domain and account
  $fqdn = GetConfigValue "DevicesDomain"
  $server = GetConfigValue "DevicesDomainServer"
  try 
  {
    Log "Export ADDevices for domain $fqdn"
    ExportADDevicesDataToCSV $fqdn $server | Out-Null    
    $n = $n + 1
  }
  catch 
  {
    Log "ERROR: Failed to process imports for domain '$fqdn'" -level "Error"
    Log "" -level "Error"
    $error[0] | Log -level "Error"
    return $false
  }

  return $true
}

###########################################################################
# ExportADDevicesDataAlt
# uses the same processing sequence as ProcessDomainsForADDeviced

function ExportADDevicesDataAlt
{
  Log ""
  Log "Export domains for ADDevices:"

  #Get-Command -module sqlserver

  $dbserver = GetConfigValue "BeaconStagingDBServer"
  $dbname = GetConfigValue "BeaconStagingDBName"
  $n = 1

  # loop through the configured set of domains
  Read-SqlTableData -ServerInstance $dbserver -DatabaseName $dbname -SchemaName "dbo" -TableName "ADDomains" -TopN 10 |
  ForEach-Object {
    $flat = $($_.Domain)
    $fqdn = ($_.FQDN)
    $server = ($_.DomainServer)    
    try 
    {    
      Log "Export ADDevices for domain $fqdn"
      ExportADDevicesDataToCSV $fqdn $server | Out-Null    
      $n = $n + 1
    }
    catch 
    {
      Log "ERROR: Failed to process imports for domain '$flat'" -level "Error"
      Log "" -level "Error"
      $error[0] | Log -level "Error"
      return $false
    }
  }
  Log ""  

  return $true
}

###########################################################################
# ImportADDevicesData (test routine)

function ImportADDevicesData
{
  # get reader domain and account
  $devicesDomain = GetConfigValue "DevicesDomain"
  $devicesDomainerver = GetConfigValue "DevicesDomainServer"    

  ImportADDevicesFromCSV $devicesDomain | Out-Null

  return $true
}

###########################################################################
# LoadSourceDataIntoStaging (test routine)

function LoadSourceDataIntoStaging
{
  # get reader domain and account
  $devicesDomain = GetConfigValue "DevicesDomain"
  $devicesDomainServer = GetConfigValue "DevicesDomainServer"    

  #WriteADDevicesToToStaging $devicesDomain $devicesDomainServer | Out-Null

  ExportADDevicesDataToCSV $devicesDomain $devicesDomainServer | Out-Null  
  ImportADDevicesFromCSV $devicesDomain | Out-Null  

  return $true
}
