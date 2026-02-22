###########################################################################
# Copyright (C) 2018 Flexera Software
###########################################################################

$LibraryScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
###########################################################################
#region Register C# Credentials Manager class

<#
.Synopsis
  Provides access to Windows CredMan basic functionality for client scripts
#>

$PsCredMan = $null
try
{
	$PsCredMan = [PsUtils.CredMan]
}
catch
{
	#only remove the error we generate
	$Error.RemoveAt($Error.Count-1)
}
if($null -eq $PsCredMan)
{
  [String]$PsCredmanUtils = Join-Path $LibraryScriptPath "CredManWrapper.cs"
	Add-Type -path $PsCredmanUtils
}

#endregion


###########################################################################
###########################################################################
#region Main CredMan library functions

###########################################################################
# Check if stored user credentials for Target (CredentialName) exist

function StoredCredentialsExist([string]$Target, [string]$CredType = "GENERIC")
{   
  # initial for credentials registration
   # may be [PsUtils.CredMan+Credential] or [Management.Automation.ErrorRecord] 
  [Object] $cred = Read-Creds $Target $CredType 
  if($null -eq $cred) 
  { 
    Log "Credential for '$Target' as '$CredType' type was not found." 
    return $false
  } 
  if ($cred -is [Management.Automation.ErrorRecord]) 
  { 
    Log "Get Credential for '$Target' as '$CredType' type returned error" 
    return $false
  }
  return $true
}

###########################################################################
# Get stored user credentials for Target (CredentialName) call

function GetStoredPsCredential([string]$Target, [string]$CredType = "GENERIC", [switch]$showPassword=$false, [switch]$Silent=$false)
{   
  # get stored credential object
  $sc = GetStoredCredential $Target -CredType $CredType -showPassword $showPassword -Silent $Silent

  $secpasswd = ConvertTo-SecureString $sc.CredentialBlob -AsPlainText -Force
  $cred = New-Object System.Management.Automation.PSCredential ($sc.UserName, $secpasswd)

  return $cred
}

###########################################################################
# Get stored user credentials for Target (CredentialName) call

function GetStoredCredential([string]$Target, [string]$CredType = "GENERIC", [switch]$showPassword=$false, [switch]$Silent=$false)
{   
  # initial for credentials registration
   # may be [PsUtils.CredMan+Credential] or [Management.Automation.ErrorRecord] 
  [Object] $cred = Read-Creds $Target $CredType 
  if($null -eq $cred) 
  { 
    Log "Credential for '$Target' as '$CredType' type was not found." 
    return ""
  } 
  if ($cred -is [Management.Automation.ErrorRecord]) 
  { 
    Log "Get Credential for '$Target' as '$CredType' type returned error" 
    return ""
  } 

  if ($showPassword) {
    $pass = $cred.CredentialBlob
  } else {
    $pass = "************"
  }

  [String] $CredStr = @" 
Found credentials as: 
  UserName  : $($cred.UserName) 
  Password  : $pass
  Target    : $($cred.TargetName.Substring($cred.TargetName.IndexOf("=")+1)) 
  Updated   : $([String]::Format("{0:yyyy-MM-dd HH:mm:ss}", $cred.LastWritten.ToUniversalTime())) UTC 
  Comment   : $($cred.Comment) 
"@
  if (!$Silent) { 
    Log ""
    Log $CredStr
    Log ""
  }
  return $cred
}


###########################################################################
# Register user credentials

function RegisterCredentials([string]$User, [string]$Password, [string]$Target, [string]$Comment, [string]$CredType = "GENERIC", [string]$CredPersist = "LOCAL_MACHINE", [switch]$showPassword=$false)
{  
  # initial for credentials registration
  # may be [Int32] or [Management.Automation.ErrorRecord] 
  [Object] $Results = Write-Creds $Target $User $Password $Comment $CredType $CredPersist 
  if ($Results -eq 0) 
  { 
    [Object] $newcred = Read-Creds $Target $CredType 
    if ($null -eq $newcred) 
    { 
      Log "Credentials for '$Target', '$User' was not found." 
      return $false
    } 
    if($newcred -is [Management.Automation.ErrorRecord]) 
    { 
      Log "Credentials for '$Target', '$User' found." 
      return $true
    }    

    if ($showPassword) {
      $pass = $Password
    } else {
      $pass = "************"
    }
    
    [String] $CredStr = @" 
Successfully wrote or updated credentials as: 
  UserName  : $($newcred.UserName) 
  Password  : $pass    
  Target    : $($newcred.TargetName.Substring($newcred.TargetName.IndexOf("=")+1)) 
  Updated   : $([String]::Format("{0:yyyy-MM-dd HH:mm:ss}", $newcred.LastWritten.ToUniversalTime())) UTC 
  Comment   : $($newcred.Comment) 
"@ 
    Log ""
    Log $CredStr
    Log ""     
  }
  return $true
}


###########################################################################
# Credentials: Prompt user for, then register user credentials

function PromptRegisterCredentials([string]$prompt, [string]$caption, [string]$message, [string]$userName, [string]$targetName, [switch]$noCheck, [switch]$showPassword=$false)
{
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement

	Write-Host $prompt
	while ($true) {
    $CredentialType = [System.Management.Automation.PSCredentialTypes]::Generic
    $ValidateOption = [System.Management.Automation.PSCredentialUIOptions]::None	
	
		$cred = $Host.UI.PromptForCredential($caption, $message, $userName, $targetName, $CredentialType, $ValidateOption)
		if (!$cred) { # Cancelled?
			return $null
		}

		Write-Host ""
    $svcUserName = $cred.UserName
 	  $svcUserPassword = $cred.GetNetworkCredential().Password

		if ($noCheck) {
			$validated = $true
		} else {
			$domain = $cred.UserName -replace "\\.*", ""
			if ($domain) {
				$ds = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $domain)
			} else {
				$ds = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine, $env:COMPUTERNAME)
			}

			try {
				$validated = $ds.ValidateCredentials(($cred.UserName -replace ".*\\", ""), $cred.GetNetworkCredential().Password)
			}
			catch
			{
				$validated = $false
				# Ignore exception
			}
		}

		if ($validated) {
			# Register the validated credentials
      RegisterCredentials $svcUserName $svcUserPassword $targetName $message -CredType "GENERIC" -CredPersist "LOCAL_MACHINE" -showPassword $showPassword
			return $cred
		}

		Write-Warning "Failed to verify username $($cred.UserName) and password. Please try again..."
	}
}

#endregion


###########################################################################
###########################################################################
#region Internal Tools

[HashTable] $ErrorCategory = @{0x80070057 = "InvalidArgument";
                               0x800703EC = "InvalidData";
                               0x80070490 = "ObjectNotFound";
                               0x80070520 = "SecurityError";
                               0x8007089A = "SecurityError"}

###########################################################################
function Get-CredType
{
	Param
	(
		[Parameter(Mandatory=$true)][ValidateSet("GENERIC",
												  "DOMAIN_PASSWORD",
												  "DOMAIN_CERTIFICATE",
												  "DOMAIN_VISIBLE_PASSWORD",
												  "GENERIC_CERTIFICATE",
												  "DOMAIN_EXTENDED",
												  "MAXIMUM",
												  "MAXIMUM_EX")][String] $CredType
	)
	
	switch($CredType)
	{
		"GENERIC" {return [PsUtils.CredMan+CRED_TYPE]::GENERIC}
		"DOMAIN_PASSWORD" {return [PsUtils.CredMan+CRED_TYPE]::DOMAIN_PASSWORD}
		"DOMAIN_CERTIFICATE" {return [PsUtils.CredMan+CRED_TYPE]::DOMAIN_CERTIFICATE}
		"DOMAIN_VISIBLE_PASSWORD" {return [PsUtils.CredMan+CRED_TYPE]::DOMAIN_VISIBLE_PASSWORD}
		"GENERIC_CERTIFICATE" {return [PsUtils.CredMan+CRED_TYPE]::GENERIC_CERTIFICATE}
		"DOMAIN_EXTENDED" {return [PsUtils.CredMan+CRED_TYPE]::DOMAIN_EXTENDED}
		"MAXIMUM" {return [PsUtils.CredMan+CRED_TYPE]::MAXIMUM}
		"MAXIMUM_EX" {return [PsUtils.CredMan+CRED_TYPE]::MAXIMUM_EX}
	}
}

function Get-CredPersist
{
	Param
	(
		[Parameter(Mandatory=$true)][ValidateSet("SESSION",
												  "LOCAL_MACHINE",
												  "ENTERPRISE")][String] $CredPersist
	)
	
	switch($CredPersist)
	{
		"SESSION" {return [PsUtils.CredMan+CRED_PERSIST]::SESSION}
		"LOCAL_MACHINE" {return [PsUtils.CredMan+CRED_PERSIST]::LOCAL_MACHINE}
		"ENTERPRISE" {return [PsUtils.CredMan+CRED_PERSIST]::ENTERPRISE}
	}
}

#endregion

###########################################################################
###########################################################################
#region Dot-Sourced API

function Del-Creds
{
<#
.Synopsis
  Deletes the specified credentials

.Description
  Calls Win32 CredDeleteW via [PsUtils.CredMan]::CredDelete

.INPUTS
  See function-level notes

.OUTPUTS
  0 or non-0 according to action success
  [Management.Automation.ErrorRecord] if error encountered

.PARAMETER Target
  Specifies the URI for which the credentials are associated
  
.PARAMETER CredType
  Specifies the desired credentials type; defaults to 
  "CRED_TYPE_GENERIC"
#>

	Param
	(
		[Parameter(Mandatory=$true)][ValidateLength(1,32767)][String] $Target,
		[Parameter(Mandatory=$false)][ValidateSet("GENERIC",
												  "DOMAIN_PASSWORD",
												  "DOMAIN_CERTIFICATE",
												  "DOMAIN_VISIBLE_PASSWORD",
												  "GENERIC_CERTIFICATE",
												  "DOMAIN_EXTENDED",
												  "MAXIMUM",
												  "MAXIMUM_EX")][String] $CredType = "GENERIC"
	)
	
	[Int] $Results = 0
	try
	{
		$Results = [PsUtils.CredMan]::CredDelete($Target, $(Get-CredType $CredType))
	}
	catch
	{
		return $_
	}
	if(0 -ne $Results)
	{
		[String] $Msg = "Failed to delete credentials store for target '$Target'"
		[Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
		[Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, $Results.ToString("X"), $ErrorCategory[$Results], $null)
		return $ErrRcd
	}
	return $Results
}

###########################################################################

function Enum-Creds
{
<#
.Synopsis
  Enumerates stored credentials for operating user

.Description
  Calls Win32 CredEnumerateW via [PsUtils.CredMan]::CredEnum

.INPUTS
  

.OUTPUTS
  [PsUtils.CredMan+Credential[]] if successful
  [Management.Automation.ErrorRecord] if unsuccessful or error encountered

.PARAMETER Filter
  Specifies the filter to be applied to the query
  Defaults to [String]::Empty
  
#>

	Param
	(
		[Parameter(Mandatory=$false)][AllowEmptyString()][String] $Filter = [String]::Empty
	)
	
	[PsUtils.CredMan+Credential[]] $Creds = [Array]::CreateInstance([PsUtils.CredMan+Credential], 0)
	[Int] $Results = 0
	try
	{
		$Results = [PsUtils.CredMan]::CredEnum($Filter, [Ref]$Creds)
	}
	catch
	{
		return $_
	}
	switch($Results)
	{
        0 {break}
        0x80070490 {break} #ERROR_NOT_FOUND
        default
        {
    		[String] $Msg = "Failed to enumerate credentials store for user '$Env:UserName'"
    		[Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
    		[Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, $Results.ToString("X"), $ErrorCategory[$Results], $null)
    		return $ErrRcd
        }
	}
	return $Creds
}

###########################################################################

function Read-Creds
{
<#
.Synopsis
  Reads specified credentials for operating user

.Description
  Calls Win32 CredReadW via [PsUtils.CredMan]::CredRead

.INPUTS

.OUTPUTS
  [PsUtils.CredMan+Credential] if successful
  [Management.Automation.ErrorRecord] if unsuccessful or error encountered

.PARAMETER Target
  Specifies the URI for which the credentials are associated
  If not provided, the username is used as the target
  
.PARAMETER CredType
  Specifies the desired credentials type; defaults to 
  "CRED_TYPE_GENERIC"
#>

	Param
	(
		[Parameter(Mandatory=$true)][ValidateLength(1,32767)][String] $Target,
		[Parameter(Mandatory=$false)][ValidateSet("GENERIC",
												  "DOMAIN_PASSWORD",
												  "DOMAIN_CERTIFICATE",
												  "DOMAIN_VISIBLE_PASSWORD",
												  "GENERIC_CERTIFICATE",
												  "DOMAIN_EXTENDED",
												  "MAXIMUM",
												  "MAXIMUM_EX")][String] $CredType = "GENERIC"
	)
	
	if("GENERIC" -ne $CredType -and 337 -lt $Target.Length) #CRED_MAX_DOMAIN_TARGET_NAME_LENGTH
	{
		[String] $Msg = "Target field is longer ($($Target.Length)) than allowed (max 337 characters)"
		[Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
		[Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, 666, 'LimitsExceeded', $null)
		return $ErrRcd
	}
	[PsUtils.CredMan+Credential] $Cred = New-Object PsUtils.CredMan+Credential
    [Int] $Results = 0
	try
	{
		$Results = [PsUtils.CredMan]::CredRead($Target, $(Get-CredType $CredType), [Ref]$Cred)
	}
	catch
	{
		return $_
	}
	
	switch($Results)
	{
        0 {break}
        0x80070490 {return $null} #ERROR_NOT_FOUND
        default
        {
    		[String] $Msg = "Error reading credentials for target '$Target' from '$Env:UserName' credentials store"
    		[Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
    		[Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, $Results.ToString("X"), $ErrorCategory[$Results], $null)
    		return $ErrRcd
        }
	}
	return $Cred
}

###########################################################################

function Write-Creds
{
<#
.Synopsis
  Saves or updates specified credentials for operating user

.Description
  Calls Win32 CredWriteW via [PsUtils.CredMan]::CredWrite

.INPUTS

.OUTPUTS
  [Boolean] true if successful
  [Management.Automation.ErrorRecord] if unsuccessful or error encountered

.PARAMETER Target
  Specifies the URI for which the credentials are associated
  If not provided, the username is used as the target
  
.PARAMETER UserName
  Specifies the name of credential to be read
  
.PARAMETER Password
  Specifies the password of credential to be read
  
.PARAMETER Comment
  Allows the caller to specify the comment associated with 
  these credentials
  
.PARAMETER CredType
  Specifies the desired credentials type; defaults to 
  "CRED_TYPE_GENERIC"

.PARAMETER CredPersist
  Specifies the desired credentials storage type;
  defaults to "CRED_PERSIST_ENTERPRISE"
#>

	Param
	(
		[Parameter(Mandatory=$false)] [ValidateLength(0,32676)] [String] $Target,
		[Parameter(Mandatory=$true)] [ValidateLength(1,512)] [String] $UserName,
		[Parameter(Mandatory=$true)] [ValidateLength(1,512)] [String] $Password,
		[Parameter(Mandatory=$false)] [ValidateLength(0,256)] [String] $Comment = [String]::Empty,
		[Parameter(Mandatory=$false)] [ValidateSet("GENERIC","DOMAIN_PASSWORD","DOMAIN_CERTIFICATE","DOMAIN_VISIBLE_PASSWORD","GENERIC_CERTIFICATE","DOMAIN_EXTENDED","MAXIMUM","MAXIMUM_EX")] [String] $CredType = "GENERIC",
		[Parameter(Mandatory=$false)] [ValidateSet("SESSION", "LOCAL_MACHINE", "ENTERPRISE")] [String] $CredPersist = "ENTERPRISE"
	)

	if([String]::IsNullOrEmpty($Target))
	{
		$Target = $UserName
	}
	if("GENERIC" -ne $CredType -and 337 -lt $Target.Length) #CRED_MAX_DOMAIN_TARGET_NAME_LENGTH
	{
		[String] $Msg = "Target field is longer ($($Target.Length)) than allowed (max 337 characters)"
		[Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
		[Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, 666, 'LimitsExceeded', $null)
		return $ErrRcd
	}
  if([String]::IsNullOrEmpty($Comment))
  {
    $Comment = [String]::Format("Last edited by {0}\{1} on {2}",
                                $Env:UserDomain,
                                $Env:UserName,
                                $Env:ComputerName)
  }
	[String] $DomainName = [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName
	[PsUtils.CredMan+Credential] $Cred = New-Object PsUtils.CredMan+Credential
	switch($Target -eq $UserName -and 
		   ("CRED_TYPE_DOMAIN_PASSWORD" -eq $CredType -or "CRED_TYPE_DOMAIN_CERTIFICATE" -eq $CredType))
	{
		$true  {$Cred.Flags = [PsUtils.CredMan+CRED_FLAGS]::USERNAME_TARGET}
		$false  {$Cred.Flags = [PsUtils.CredMan+CRED_FLAGS]::NONE}
	}
	$Cred.Type = Get-CredType $CredType
	$Cred.TargetName = $Target
	$Cred.UserName = $UserName
	$Cred.AttributeCount = 0
	$Cred.Persist = Get-CredPersist $CredPersist
	$Cred.CredentialBlobSize = [Text.Encoding]::Unicode.GetBytes($Password).Length
	$Cred.CredentialBlob = $Password
	$Cred.Comment = $Comment

	[Int] $Results = 0
	try
	{
		$Results = [PsUtils.CredMan]::CredWrite($Cred)
	}
	catch
	{
		return $_
	}

	if(0 -ne $Results)
	{
		[String] $Msg = "Failed to write to credentials store for target '$Target' using '$UserName', '$Password', '$Comment'"
		[Management.ManagementException] $MgmtException = New-Object Management.ManagementException($Msg)
		[Management.Automation.ErrorRecord] $ErrRcd = New-Object Management.Automation.ErrorRecord($MgmtException, $Results.ToString("X"), $ErrorCategory[$Results], $null)
		return $ErrRcd
	}
	return $Results
}

#endregion
