###########################################################################
# Copyright (C) 2019 Crayon Australia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
# ConfigureCommonAdapterSettings
# Force the preferences to be loaded so that the caller will be prompted 
# if the config value is not already set

function ConfigureCommonAdapterSettings()
{
  Log "Configuring the settings that are common across multiple adapters"

  $DataImportFolder = GetConfigValue "DataImportFolder"
  $DataImportShare = GetConfigValue "DataImportShare"
  $UserDomain = GetConfigValue "UserDomain"

  $DSNName = GetConfigValue "ODBCDSNName"
  
  CreateCSVDSN $DSNName $DataImportFolder

  return $true
}


###########################################################################
# CreateCSVDSN
# Check if one exists already and remove it if it does

function CreateCSVDSN([string]$DSNName, [string]$DefaultDir) 
{
  $dsn = Get-OdbcDsn -Name $DSNName -DsnType "System" -Platform "32-bit" -ErrorAction SilentlyContinue
  if ($dsn -ne $null) {
    Remove-OdbcDsn -Name $DSNName -DsnType "System" -Platform "32-bit"    
  }
  Add-OdbcDsn -DsnType System -Platform 32-bit -Name $DSNName -DriverName "Microsoft Text Driver (*.txt; *.csv)" -SetPropertyValue DefaultDir=$DefaultDir
}

###########################################################################
# CreateFileShare

function CreateFileShare ([string]$Foldername, [string]$Sharename) 
{
  $Foldername = $folderName.Trimend("\ ")
  if (!(Test-Path $Foldername)) 
  {
    Log "The folder $Foldername does not exist." -level "Error"
    return $false
  }
    
  $Shares=[WmiClass]"WIN32_Share"
  If (!(Get-WmiObject Win32_Share -filter "name='$Sharename'")) 
  { 
    Log "Creating the '$Sharename' file share on the folder '$Foldername'."
    try 
    {
      $Shares.Create($Foldername,$Sharename,0) | Out-Null
      # Remove default access to everyone
      Revoke-SmbShareAccess -name $Sharename -AccountName Everyone -Force -ErrorAction Stop | Out-Null
    } 
    catch 
    {
      Log "Failed to create the '$Sharename' file share on the folder '$Foldername': $_" -level "Error"
      return $false
    }
    
    # Revisit: 
    # The above call doesn't seem to throw any exceptions if it fails to create the share.  
    # Need to investigate options for ensuring that exceptions are detected.
    # The scripting below is a workaround to ensure that the function does not continue
    # if the file share is not created
    If (!(Get-WmiObject Win32_Share -filter "name='$Sharename'")) 
    { 
      Log "Failed to create the '$Sharename' file share on the folder '$Foldername'." -level "Error"
      return $false
    }
  }
  return $true
}

###########################################################################
# GrantShareAccess

function GrantShareAccess([string]$Sharename, [string] $Principal)
{
  try 
  {
    Log "Granting permission to '$Principal' to access the '$Sharename' file share."
    Grant-SmbShareAccess -name $Sharename -AccountName $Principal -AccessRight Full -Force -ErrorAction Stop | Out-Null
  } 
  catch 
  {
    Log "Failed to grant permission to '$Principal' to access the '$Sharename' file share: $_" -level "Error"
    return $false
  }
  return $true
}

###########################################################################
# GrantFolderAccess

function GrantFolderAccess([string]$Foldername, [string] $Principal)
{
  $Foldername = $folderName.Trimend("\ ")
  if (!(Test-Path $Foldername)) 
  {
    Log "The folder $Foldername does not exist." -level "Error"
    return $false
  }
  
  try 
  {
    Log "Granting permission to '$Principal' to access the '$Foldername' folder."
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($Principal,"FullControl","ContainerInherit,ObjectInherit","None","Allow")
    $ACL = (Get-item $Foldername).getaccesscontrol("Access") 
    $ACL.SetAccessRule($AccessRule) | Out-Null
    Set-Acl $Foldername -AclObject $acl -ErrorAction Stop | Out-Null
  } 
  catch 
  {
    Log "Failed to grant permission to '$Principal' to access the '$Foldername' folder: $_" -level "Error"
    return $false
  } 
  return $true
}

###########################################################################
# ConfigureImportFileShares

function ConfigureImportFileShares
{
  $dataImportFolder = GetConfigValue "DataImportFolder"
  $dataImportFolder = $dataImportFolder.Trimend("\ ")
  if (!(Test-Path $dataImportFolder)) 
  {
    New-Item -Path $dataImportFolder -ItemType Directory | Out-Null
  }
  
  # Create the share
  $dataImportShare = GetConfigValue "DataImportShare" 
  if ($dataImportFolder) 
  {
    if (!(CreateFileShare $dataImportFolder $dataImportShare)) 
    {
      return $false
    }
  }

  # Grant access to the share
  # Currently only administrators will have access to the share
  $principals = (,".\Administrators")
  $principals | % 
  {
    $ok = GrantShareAccess $dataImportShare $_
    if (!($ok)) 
    {
      return $false
    }

    $ok = GrantFolderAccess $dataImportFolder $_
    if (!($ok)) 
    {
      return $false
    }
  }
  return $true
}


###########################################################################
# Install Beacon Business Adapters

function InstallBeaconBusinessAdapters
{
  $beaconFolder = Join-Path $env:ProgramData "Flexera Software\Beacon"  

  if (!(Test-Path $beaconFolder -PathType Container)) {
    Log "" -level Error
    Log "ERROR: The business adapter folder '$beaconFolder' does not exist on this server. Verify that the beacon software is installed." -level Error

    return $false
  }

  $source = Join-Path $ScriptPath "BusinessAdapter"

  Log "Copying business adapters from '$source' to '$beaconFolder'"
  if (!(CopyFiles $source $beaconFolder)) {
    return $false
  }

  Log "Business adapters installed"

  return $true
}


###########################################################################
# Credentials: Register user domain account credentials 

function RegisterUserDomainCredentials
{  
  # get the service account name and pick a default target
  $userName = GetConfigValue "UserDomainAccount"
  $targetName = GetConfigValue "UserDomain"

  # get and register the user name and credentials
  $cred = PromptRegisterCredentials `
    "Request user provides credentials ..." `
    "Credentials $Target" `
    "Enter user credentials to be stored for later processing" `
    $userName `
    $targetName `
    -noCheck `
    -showPassword    

  if (!$cred) { # Canceled?
    Log "Configuration canceled by user"
    return $false
  }
  return $true
}


###########################################################################
# Credentials: Check user domain service account credentials 

function CheckUserDomainCredentials
{  
  # get the service account name and pick a default target
  $targetName = GetConfigValue "UserDomain"
  GetStoredCredential $targetName -showPassword | Out-Null

  return $true
}

###########################################################################
# Credentials: Register devices domain account credentials 

function RegisterDeviceDomainCredentials
{  
  # get the service account name and pick a default target
  $devicesName = GetConfigValue "DevicesDomainAccount"
  $targetName = GetConfigValue "DevicesDomain"

  # get and register the user name and credentials
  $cred = PromptRegisterCredentials `
    "Request user provides credentials ..." `
    "Credentials $Target" `
    "Enter user credentials to be stored for later processing" `
    $devicesName `
    $targetName `
    -noCheck `
    -showPassword    

  if (!$cred) { # Canceled?
    Log "Configuration canceled by user"
    return $false
  }
  return $true
}

###########################################################################
# Credentials: Check devices domain service account credentials 

function CheckDevicesDomainCredentials
{  
  # get the service account name and pick a default target
  $targetName = GetConfigValue "DevicesDomain"
  GetStoredCredential $targetName -showPassword | Out-Null

  return $true
}


###########################################################################
# Process import for the configured domain set

function ProcessDomains
{
  Log ""
  Log "List of domains to be processed:"

  # get the domain set
  $UserDomains = GetConfigValue "UserDomains"

  # loop through the configured set of domains
  $n = 1
  foreach ($dd in $UserDomains) 
  {
    try 
    {
      Log "... domain #$n = $dd"
      $n = $n + 1
    }
    catch 
    {
      Log "ERROR: Failed to process imports for domain '$dd'" -level "Error"
      Log "" -level "Error"
      $error[0] | Log -level "Error"
      return $false
    }
  }
  Log ""  

  return $true
}
