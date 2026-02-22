###########################################################################
# This script contains various functions available for use in flexadmin
# modules. These functions are not associated with any particular Flexera
# Software product(s).
#
# Copyright (C) 2015-2017 Flexera Software
###########################################################################

$FlexAdminFunctionsScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
# Validate the value provided for a configuration setting is valid by
# ensuring that the specified file exists in the directory specified by the
# value.

function ValidateFileExistsInDir([string]$pathToCheck, [string]$value)
{
	try {
		$fullPath = Join-Path $value $pathToCheck
		$ok = Test-Path $fullPath -pathType Leaf
	}
	catch {
		$ok = $false
	}

	if (!$ok) {
		Write-Host ""
		Write-Warning "File not found: $fullPath"
		Write-Host ""

		return $false
	}

	return (Resolve-Path $value).ProviderPath
}


###########################################################################
# Validate that as "yes/no" or "true/false" answer has been provided. Input
# values are normalised to either "Y" or "N".

function ValidateYOrN([string]$value)
{
	if ($value -match "^y" -or $value -match "^true") {
		$value = "Y"
	}
	if ($value -match "^n" -or $value -match "^false") {
		$value = "N"
	}
	
	if ($value -ne "Y" -and $value -ne "N") {
		return $false
	}

	return $value
}


###########################################################################
# Validate the value provided for a HTTP protcol configuration setting is
# valid by ensuring that it is either "http" or "https".

function ValidateWebAccessProtocol([string]$value)
{
	if (!(("http", "https") -contains $value)) {
		Write-Host ""
		Write-Warning "Value must either be 'http' or 'https'"
		Write-Host "Please try again"
		Write-Host ""

		return $false
	}

	return $value
}


###########################################################################
# Add privileges to a specified account.
#
# Approach sourced from
# http://stackoverflow.com/questions/10187837/granting-seservicelogonright-to-a-user-from-powershell.
# LSAWrapper.cs contains C# code to configure privileges. Add-Type is
# used to compile and make this type accessible. That is done inside a
# background job since the type can only be loaded once into a single
# PowerShell process: once it has been loaded (e.g. by calling this
# function once) it can't be loaded again.

function AddPrivileges([string]$account, [string[]] $rights)
{
	Start-Job `
		-ArgumentList $FlexAdminFunctionsScriptPath, $account, $rights `
		-ScriptBlock {
			param([string]$scriptPath, [string]$account, [string[]]$rights)

			Add-Type -Path (Join-Path $scriptPath "LSAWrapper.cs")

			$rights | %{ [MyLsaWrapper.LsaWrapperCaller]::AddPrivileges($account, $_) }
		} |
	Wait-Job |
	Receive-Job |
	Log
}

###########################################################################
#

function Test-SQLConnection([string[]]$connectionParameters, [string[]]$hiddenConnectionParameters)
{
	$connectionString = $connectionParameters -Join ";"
	$filteredConnectionString = ($connectionParameters | %{ $_ -replace "Password=.*", "Password=<hidden>" }) -Join ";"
	 
	$result = $false
	try {
			# Try and connect to server
			Log "Testing the connection: $filteredConnectionString"

			$sqlConn = New-Object "Data.SqlClient.SqlConnection" $connectionString 
			$sqlConn.Open()
			
			if ($sqlConn.State -eq "Open")
			{
				$sqlConn.Close();
				Log "`tSuccessfully established the connection"
				$result = $true
			}
	} catch {
		Log "Failed to establish the connection: $($_.Exception.Message)"
	}
	
	return $result
}


###########################################################################
# Verify that a group exists in a domain, and create it as a domain local
# security group if not.

function CreateGlobalSecurityGroup([string]$qualifiedGroupName, [string]$description)
{
	$g = $qualifiedGroupName.Split("\\")
	$name = $g[1]
	$domain = $g[0]

	Log "Verifying that group '$name' in domain '$domain' exists"

	if (!(Get-Command Get-ADGroup -ErrorAction SilentlyContinue)) {
		Log "`tERROR: The PowerShell command Get-ADGroup is not defined, possibly because the 'Remote Server Administration Tools > Role Administration Tools > AD DS and AD LDS Tools > Active Directory module for Windows PowerShell' feature is not installed on this computer." -level Error
		Log "" -level Error
		Log "`tReview the information in the 'Installation' section of the page at https://technet.microsoft.com/en-us/library/dd378937(WS.10).aspx for guidance on how to install the relevant module."
		return $null
	}

	try {
		$group = Get-ADGroup $name -Server $domain
		Log "`tGroup found in domain"
	}
	catch {
		Log "`tGroup not found; creating group"
		try {
			$group = New-ADGroup $name Global -Description $description -Server $domain -PassThru
			Log "`tGroup created successfully"
		}
		catch {
			Log "`tFailed to create group '$name' in domain '$domain': $_" -Level Error
			return $null
		}
	}

	return $group
}


###########################################################################
# Verify that a user exists in a domain, and create it as a service account
# if not.

function CreateServiceAccount([string]$qualifiedAccountName)
{
	$q = $qualifiedAccountName.Split("\\")
	$name = $q[1]
	$domain = $q[0]

	Log "Verifying that user '$name' in domain '$domain' exists"

	if (!(Get-Command Get-ADUser -ErrorAction SilentlyContinue)) {
		Log "`tERROR: The PowerShell command Get-ADUser is not defined, possibly because the Active Directory module for Windows PowerShell is not installed." -level Error
		Log "`tPlease review the information in the 'Installation' section of the page at https://technet.microsoft.com/en-us/library/dd378937(WS.10).aspx to install the relevant module."
		return $null
	}

	try {
		$user = Get-ADUser $name -Server $domain
		Log "`tUser found in domain"
		
		if ($user.Enabled -eq $false) { # Explicit comparison to $false is important here; we don't want to detect $null (indicating we can't read the enabled state from AD)
			Log "`tERROR: User '$qualifiedAccountName' is disabled. This user must be enabled before proceeding." -level Error
			return $null
		}
	}
	catch {
		Log "`tUser not found; creating the user"
		
		try {
			$password = ConvertTo-SecureString -AsPlainText (GetPasswordFromConsole "Enter password for creating service account $qualifiedAccountName" -verify) -Force
			$user = New-ADUser -SamAccountName $name -Name $name -AccountPassword $password -PasswordNeverExpires $true -Enabled $true -Server $domain -PassThru
			Log "`tUser created successfully"
		}
		catch {
			Log "`tFailed to create user '$name' in domain '$domain': $_" -Level Error
			Log "`tPlease manually create and enable this user account and re-run this script" -Level Error
			return $null
		}
	}

	return $user
}


###########################################################################
# Substitute a set of attribute values in a template XML file to generate
# another XML file.
#
# Example:
#
# $source = "MyFile.template.xml"
# $dest = "MyFile.xml"
#
# $substitutions = @{
#		"/root/Imports/Import" = @{Type = "SqlServer"; ConnectionString = "Initial Catalog=MyDB;Data Source=127.0.0.1;Integrated Security=SSPI"};
#		"/root/Imports/Import/Log" = @{FileName = "c:\Temp\[IMPORT NAME]_[DATE]_[TIME].log"};
#		"/root/Imports/Import[@Name = 'Do not want']" = $null; # Deletes entire Import node
# }
#
# GenerateXMLFromTemplate $source $dest $substitutions

function GenerateXMLFromTemplate([string]$source, [string]$dest, $attributeSubstitutions)
{
	Log "Generating '$dest' from template '$source'"

	try {
		# Perform the updates
		$configXml = [xml](Get-Content $source)
		foreach ($param in $attributeSubstitutions.GetEnumerator())
		{
			Log "`tConfiguring settings matching $($param.Name)"
			$i = 0
			foreach ($node in $configXml.SelectNodes($param.Name)) {
				++$i
				Log "`t`tMatch #$i"

				$attributes = $param.Value
				if ($attributes -eq $null) {
					$node.ParentNode.RemoveChild($node)
				} else {
					foreach ($attribute in $attributes.GetEnumerator()) {
						Log "`t`t`tSet attribute $($attribute.Name) to: $($attribute.Value)"

						$node.SetAttribute($attribute.Name, $attribute.Value)
					}
				}
			}
		}

		# Generate installer response file
		$configXml.Save($dest)
	}
	catch {
		Log "Error generating file: $_" -level Error
		return $false
	}

	return $true
}
