###########################################################################
# Copyright (C) 2018 Flexera Software
###########################################################################

$LibraryScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# Get stored user credentials for Target (CredentialName) call

function GetStoredCredentials([string]$Target, [switch]$showPassword)
{   
  # initial for credentials registration
  if ( [StoredCredential]::Exists( $Target ) ) {
    $sc = [StoredCredential]::New( $Target )
  } else {
    Log "Credential for '$Target' was not found." 
    return ""
  } 

  # Credential for $Target found: $($sc.PSCredential)
  if ($showPassword) {
    $Password = $sc.PSCredential.GetNetworkCredential().Password
  } else {
    $Password = "************"
  }

  [String] $CredStr = @" 
Found credentials as: 
  UserName  : $($sc.account)
  Password  : $Password
  Target    : $Target 
"@ 
  Log $CredStr
  Log ""

  return $sc.PSCredential
}

###########################################################################
# Register user credentials

function RegisterCredentials([string]$User, [string]$Password, [string]$Target, [switch]$showPassword=$false)
{
  # initial for credentials registration
  if ( [StoredCredential]::Exists( $Target ) ) {
    Log "Credentials for '$Target', already exists."   
  }
  $sc = [StoredCredential]::Store( $Target, $User, $Password ) 

  if ($showPassword) {
    $pass = $Password
  } else {
    $pass = "************"
  }

  [String] $CredStr = @" 
Successfully wrote or updated credentials as: 
  UserName  : $($sc.PSCredential.UserName) 
  Password  : $pass
  Target    : $Target
"@ 
  Log $CredStr 
 
  return $true
}

###########################################################################
# Simple password vault access class  
#
# Example:
#
# $sc = [StoredCredential]::Store( $Target, $cred )
# #or#  $sc = [StoredCredential]::Store( $Target, $User, $Password ) 
# if ( [StoredCredential]::Exists( $Target ) ) {
#   $Password = $sc.PSCredential.GetNetworkCredential().Password
# } else {
#   Log "Credentials for '$Target', '$User' was not found." 
#   return $false
# }
#

class StoredCredential
{ 
  [System.Management.Automation.PSCredential] $PSCredential 
  [string] $account; 
  [string] $password; 
 
  # loads credential from vault 
  StoredCredential( [string] $name )
  { 
    [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]  
    $vault = New-Object Windows.Security.Credentials.PasswordVault  
    $cred = $vault.FindAllByResource($name) | select -First 1 
    $cred.retrievePassword() 
    $this.account = $cred.userName 
    $this.password = $cred.password  
    $pwd_ss = ConvertTo-SecureString $cred.password -AsPlainText -Force 
    $this.PSCredential = New-Object System.Management.Automation.PSCredential ($this.account, $pwd_ss ) 
  } 
 
  static [bool] Exists( [string] $name )
  { 
    [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]  
    $vault = New-Object Windows.Security.Credentials.PasswordVault  
    try { 
       $vault.FindAllByResource($name)  
    } 
    catch { 
      if ( $_.Exception.message -match "element not found" ) { 
        return $false 
      } 
      throw $_.exception 
    } 
    return $true 
  } 
 
 
  static [StoredCredential] Store( [string] $name, [string] $login, [string] $pwd )
  { 
    [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime] 
    $vault=New-Object Windows.Security.Credentials.PasswordVault 
    $cred=New-Object Windows.Security.Credentials.PasswordCredential($name, $login, $pwd) 
    $vault.Add($cred) 
    return [StoredCredential]::new($name) 
  } 
     
  static [StoredCredential] Store( [string] $name, [PSCredential] $pscred )
  { 
    return [StoredCredential]::Store( $name, $pscred.UserName, ($pscred.GetNetworkCredential()).Password ) 
  } 

}
# class StoredCredential

