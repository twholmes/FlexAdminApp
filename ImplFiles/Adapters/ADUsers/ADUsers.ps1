###########################################################################
# Copyright (C) 2019-2020 Crayon Australia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
# ConfigureAdapterSettings

function ConfigureAdapterSettings()
{
  Log "Configuring the settings for the AD Users adapter"

  # Force the preferences to be loaded so that the caller will be prompted
  # if the config value is not already set
  $logdir = GetConfigValue "LogDir"  
  $dbserver = GetConfigValue "BeaconStagingDBServer"
  $dbname = GetConfigValue "BeaconStagingDBName"

  # Pre-load preferences for this module
  $adServer = GetConfigValue "DevicesDomainServer"

  $dataFolder = GetConfigValue "DataImportFolder"  
  $filename = GetConfigValue "UserDataCsvFile"        
    
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
  $dest = Join-Path $beaconBusinessAdapterDirectory "ADUsers.xml"
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
# ExportADUserDataToCSV

function ExportADUserDataToCSV([string]$FQDN, [string]$DC)
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
    $exportFilename = GetConfigValue "UserDataCsvFile"        
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
      Log "Sored credentials for domain $FQDN not found"
      return $false
    }
     
    # Update export file name for this doamin    
    $dataExportFile = $dataExportFile.Replace(".csv",".$FQDN.csv")
    $csvde = "$($env:systemroot)\system32\csvde.exe"
    
    $oc = '(&(objectClass=user)(objectCategory=person))'

    Log "Update ADDevices records in Staging database for the domain: $DN"       
    Log "  using $csvde -file `"$dataExportFile`" -s `"$DC`" -r `"$oc`" -d `"$DN`" -b `"$($creduser)`" `"$($creddomain)`" `"$($cred.CredentialBlob)`" -v -j `"$dataExportFolder`""
    Write-Host ""
    & "$csvde" -file "$dataExportFile" -v -j $dataExportFolder -s $DC -r "(&(objectClass=user)(objectCategory=person))" -d $DN -b $($creduser) $($creddomain) $($cred.CredentialBlob)

    # Write out the csvde log file (diagnostic)
    #Get-Content $csvdeLogFile | foreach { Write-Host $_ }
    
    Write-Host ""
  }
  catch 
  {
    Log "ERRROR: Failed to read AD Users source data.  Details: $_" -Level Error
    return $false
  }
  return $true
}

###########################################################################
# ImportADUsersFromCSV

function ImportADUsersFromCSV([string]$FQDN)
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
    $importFilename = GetConfigValue "UserDataCsvFile"        
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
    
    $dbserver = GetConfigValue "BeaconStagingDBServer"
    $dbname = GetConfigValue "BeaconStagingDBName"

    Log "Clear old ADUser records from Staging database for domain = $FQDN"
    $ClearOldResults = "DELETE FROM [dbo].[ADUsers] WHERE [Domain] like '$FQDN'"

    #call the invoke-sqlcmdlet to execute the insert query
    Invoke-sqlcmd -ServerInstance $dbserver -Database $dbname -Query $ClearOldResults
       
    Log "Update ADUser records in Staging database for the domain: $DN"       
    Log "  using exported data in the CSV file $dataImportFile"
    Write-Host ""    
    
    $userRecords = Import-CSV $dataImportFile |   
    ForEach-Object {
      $n = $n + 1
    
      $objectclass = $($_.objectClass)  
      $DN = $($_.DN)
      $cn = (GetCanonicalName $DN).Replace("'","''")

      $LastLogonTimeStamp = ([datetime]::FromFileTime($_.lastLogonTimestamp).ToString('g'))              
      $samaccountname = $($_.sAMAccountName).Replace("'","''").Trim().TrimStart(",")
      
      $domain = $($cn.Split('/')[0])
      $location = $(GetLocation $cn)
      $bu = $(GetCorporateUnit $cn).Replace("'","''")
      
      $email = $($_.userPrincipalName).Replace("'","''")
      $principal = $($_.userPrincipalName).Replace("'","''")
      
      $surname = $($_.sn).Replace("'","''")
      $givenname = $($_.givenName).Replace("'","''")
      $title = $($_.title).Replace("'","''")
      $telephone = $($_.telephoneNumber).Replace("'","''")  

      Write-Host "." -NoNewLine          
      #Write-Host "$samaccountname, $principal, $cn"
      
      $InsertResults = @"
        INSERT INTO [dbo].[ADUsers](SAMAccountName,Domain,ExportDate,LastLogon,Location,BusinessUnit,Email,UserPrincipalName,CanonicalName)
        VALUES ('$samaccountname','$domain','$importDate','$LastLogonTimeStamp','$location','$bu','$email','$principal','$cn')
"@     
      #call the invoke-sqlcmdlet to execute the insert query
      try {  
        Invoke-sqlcmd -ServerInstance $dbserver -Database $dbname -Query $InsertResults
      }
      catch {
        Write-Host ""
        Log "ERROR: Invoke-sqlcmd '$UpdateResults' failed" -level Error
        Write-Host ""
        $error[0] | Log -level Error
        Write-Host ""       
      }      
           
      #update record with additional attributes
      $UpdateResults = @"
        UPDATE [dbo].[ADUsers]
        SET          
          Surname = '$surname',      
          GivenName = '$givenname',
          Title = '$title',
          TelephoneNumber = '$telephone'
        WHERE SAMAccountName like '$samaccountname'
"@     
      #call the invoke-sqlcmdlet to execute the update query
    	try {  
        Invoke-sqlcmd -ServerInstance $dbserver -Database $dbname -Query $UpdateResults -AbortOnError
      }
 	    catch {
 	      Log ""
  	    Log "ERROR: Invoke-sqlcmd '$UpdateResults' failed" -level Error
		    Log "" -level Error
		    $error[0] | Log -level Error
		    return $false
      }
    }

    Write-Host " ($($n-1) records written)"
    Write-Host ""    
  }
  catch 
  {
    Log "ERRROR: Failed to import AD Users source data.  Details: $_" -Level Error
    return $false
  }
  return $true
}

###########################################################################
# Process import for the configured domain set

function ProcessDomainsForADUsers
{
  Log ""
  Log "Processing domains for ADUsers:"

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
      Log "... process ADUsers for domain #$n = $flat"
      ExportADUserDataToCSV $fqdn $server | Out-Null  
      ImportADUsersFromCSV $fqdn | Out-Null
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
# WriteADUserToStaging

function WriteADUserToToStaging([string]$FQDN, [string]$DC)
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
    
    $dbserver = GetConfigValue "BeaconStagingDBServer"
    $dbname = GetConfigValue "BeaconStagingDBName"

    Log "Clear old ADUser records from Staging database for domain = $FQDN"
    $ClearOldResults = "DELETE FROM [dbo].[ADUsers] WHERE [Domain] like '$FQDN'"

    #call the invoke-sqlcmdlet to execute the insert query
    Invoke-sqlcmd -ServerInstance $dbserver -Database $dbname -Query $ClearOldResults
       
    Log "Update ADUser records in Staging database for the domain: $DN"       
    Log "  using GetAdUser -Server $DC"
    $array = Get-AdUser -SearchBase $DN -Server $DC -Credential $cred -LDAPFilter "(!userAccountControl:1.2.840.113556.1.4.803:=2)" -properties canonicalname,mail,userPrincipalName | 
    ForEach-Object {
      $samaccountname = $($_.SamAccountName)
      $cn = $($_.CanonicalName)
      $domain = $($_.CanonicalName.Split('/')[0])
      $exportedate = $($_.ExportDate)
      $LastLogonTimeStamp = ([datetime]::FromFileTime($_.lastLogonTimestamp).ToString('g'))      
      $location = $(GetLocation $_.CanonicalName)
      $bu = $(GetCorporateUnit $_.CanonicalName)
      $email = $($_.mail).Replace("'","''")
      $principal = $($_.userPrincipalName)      
      
      $surname = $($_.sn).Replace("'","''")
      $givenname = $($_.givenName).Replace("'","''")
      $title = $($_.title)
      $telephone = $($_.telephoneNumber)      

      Write-Host "$samaccountname, $principal, $cn"
      
      $InsertResults = @"
        INSERT INTO [Staging].[dbo].[ADUsers](SAMAccountName,Domain,ExportDate,LastLogon,Location,BusinessUnit,Email,UserPrincipalName,CanonicalName)
        VALUES ('$samaccountname','$domain','$importDate','$LastLogonTimeStamp','$location','$bu','$email','$principal','$cn')
"@     
      #call the invoke-sqlcmdlet to execute the insert query
      Invoke-sqlcmd -ServerInstance $dbserver -Database $dbname -Query $InsertResults
           
      #update record with additional attributes
      $UpdateResults = @"
        UPDATE [dbo].[ADUsers]
        SET          
          Surname = '$surname',      
          GivenName = '$givenname',
          Title = '$title',
          TelephoneNumber = '$telephone',
        WHERE SAMAccountName like '$samAccountName'
"@     
      #call the invoke-sqlcmdlet to execute the update query
    	try {  
        Invoke-sqlcmd -ServerInstance $dbserver -Database $dbname -Query $UpdateResults -AbortOnError
      }
 	    catch {
 	      Log ""
  	    Log "ERROR: Invoke-sqlcmd '$UpdateResults' failed" -level Error
		    Log "" -level Error
		    $error[0] | Log -level Error
		    return $false
      }
       
    }
    Write-Host ""
  }
  catch 
  {
    Log "ERRROR: Failed to read AD Users source data.  Details: $_" -Level Error
    return $false
  }
  return $true
}


###########################################################################
###########################################################################
# TEST ROUTINES

###########################################################################
# ExportADUserData

function ExportADUserData
{
  # get reader domain and account
  $fqdn = GetConfigValue "UserDomain"
  $server = GetConfigValue "UserDomainServer"    
  try 
  {
    Log "Export ADUsers for domain $fqdn"
    ExportADUserDataToCSV $fqdn $server | Out-Null  
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
# ExportADUserDataAlt
# uses the same processing sequence as ProcessDomainsForADUsers

function ExportADUserDataAlt
{
  Log ""
  Log "Export domains for ADUsers:"

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
      Log "Export ADUsers for domain #$n = $flat"
      ExportADUserDataToCSV $fqdn $server | Out-Null  
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
# ImportADUserData

function ImportADUserData
{
  # get reader domain and account
  $userDomain = GetConfigValue "UserDomain"
  $userDomainServer = GetConfigValue "UserDomainServer"    
  Log "User domain = $userDomain"

  ImportADUsersFromCSV $userDomain | Out-Null

  return $true
}

###########################################################################
# LoadSourceDataIntoStaging

function LoadSourceDataIntoStaging
{
  # get reader domain and account
  $userDomain = GetConfigValue "UserDomain"
  $userDomainServer = GetConfigValue "UserDomainServer"    

  #WriteADUserToToStaging $UserDomain $UserDomainServer | Out-Null

  ExportADUserDataToCSV $userDomain $userDomainServer | Out-Null  
  ImportADUsersFromCSV $userDomain | Out-Null  

  return $true
}


###########################################################################
###########################################################################
# OTHER CODE SNIPETS

# This could be used instead of an & call to csvde
  #$pscred = GetStoredPsCredential $FQDN # -showPassword    
  #$args = "-file `"$dataExportFile`" -s `"$DC`" -r `"$oc`" -d `"$DN`" -j `"$dataExportFolder`" -v"
  #Start-Process -FilePath $csvde -Wait -Credential $pscred -ArgumentList $args -NoNewWindow


