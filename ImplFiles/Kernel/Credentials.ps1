###########################################################################
# Copyright (C) 2020 Crayon Australia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Credentials: Register service account credentials 

function RegisterServiceAccountCredentials
{  
  # get the service account name and pick a default target
  $userName = GetConfigValue "FlexeraServiceAccount"
  $targetName = GetConfigValue "FlexeraServerFQDN"

  # get and register the user name and credentials
  $cred = PromptRegisterCredentials `
    "Request user provides credentials ..." `
    "Credentials Target" `
    "Enter user credentials to be stored for later processing" `
    $userName `
    $targetName `
    -noCheck `
    -showPassword    

  if (!$cred) { # Cancelled?
    Log "Configuration cancelled by user"
    return $false
  }
  return $true
}

###########################################################################
# Credentials: Check service account credentials 

function CheckServiceAccountCredentials
{  
  # get the service account name and pick a default target
  $targetName = GetConfigValue "FlexeraServerFQDN"
  GetStoredCredential $targetName -showPassword | Out-Null

  return $true
}

