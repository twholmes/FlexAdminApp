###########################################################################
# This script contains various functions available for use in flexadmin
# modules. These functions are not associated with any particular Flexera
# Software product(s).
#
# Copyright (C) 2019 Crayon Australia
###########################################################################

$ShellFunctionsScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
# Get the installed FNMS product version

function GetFNMSVersion
{
	$id = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft" -name ComplianceVersion -ErrorAction Ignore).ComplianceVersion
	if (-not $id) {
		$id = (Get-ItemProperty "HKLM:\SOFTWARE\ManageSoft Corp\ManageSoft" -name ComplianceVersion -ErrorAction Ignore).ComplianceVersion
	}
	return $id
}

###########################################################################
# Get the installed FNMS registry key value

function GetManageSoftRegKeyValue([string]$PropertyName, [string]$SubKey)
{
  $basekey = "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft"
  $key = Join-Path $basekey $SubKey

  $val = (Get-ItemProperty $key -name $PropertyName -ErrorAction Ignore).$PropertyName
  if (-not $val) {
    $basekey = "HKLM:\SOFTWARE\ManageSoft Corp\ManageSoft"
    $key = Join-Path $basekey $SubKey
    $val = (Get-ItemProperty $key -name $PropertyName -ErrorAction Ignore).$PropertyName
	}
	return $val
}

function GetManageSoftRegKeyValue51([string]$PropertyName, [string]$SubKey)
{
  # what version of PowerShell are we running?
  $psv = $PSVersionTable.PSVersion
  $psva = $psv.ToString().Split(".")
  $psvn = 10 * $psva[0] + $psva[1]

  $basekey = "HKLM:\SOFTWARE\Wow6432Node\ManageSoft Corp\ManageSoft"
  $key = Join-Path $basekey $SubKey

  if ($psvn -lt 51) {
    $val = "powershell error"
  } else {
	  $val = Get-ItemPropertyValue $key -name $PropertyName
	  if (-not $val) {
      $basekey = "HKLM:\SOFTWARE\ManageSoft Corp\ManageSoft"
      $key = Join-Path $basekey $SubKey
	  	$val = Get-ItemPropertyValue $key -name $PropertyName
	  }
	}
	return $val
}

###########################################################################
# Get the installed FNMS registry key value

function GetFlexeraRegKeyValue([string]$PropertyName, [string]$SubKey)
{
  $basekey = "HKLM:\SOFTWARE\Wow6432Node\Flexera Software\FlexNet Manager Platform"
  $key = Join-Path $basekey $SubKey

  $val = (Get-ItemProperty $key -name $PropertyName -ErrorAction Ignore).$PropertyName
  if (-not $val) {
    $basekey = "HKLM:\SOFTWARE\Flexera Software\FlexNet Manager Platform"
    $key = Join-Path $basekey $SubKey
    $val = (Get-ItemProperty $key -name $PropertyName -ErrorAction Ignore).$PropertyName
	}
	return $val
}


###########################################################################
# Load flexadmin configuration from an XML file, recursively loading

#function LoadFlexAdminConfig([string]$configFile, [System.Collections.ArrayList]$moduleConfigs)
#{
#	Log "`tLoading flexadmin configuration from '$configFile'" -level Debug
#
#		if ($f.StoreInRegistry -eq "true") {
#			$k = "HKLM:\SOFTWARE\Flexera Software"
#			$n = "FlexAdminSettings"
#
#			$af = (Get-ItemProperty $k -name $n -ErrorAction Ignore).$n
#
#			if (!$af) {
#				try {
#					do {
#						$af = Read-Host -prompt "Enter name of FlexAdmin config settings file for *this* computer (example name: fnms.settings)"
#						$af = JoinPathIfRelative $af (Split-Path $configFile)
#					} while (Test-Path $af -PathType Container) # Do not accept a directory name (or if no value is provided at the prompt)
#
#					# Store path to settings file in registry
#					New-Item -Path (Split-Path $k) -Name (Split-Path -Leaf $k) -ErrorAction Ignore | Out-Null
#					Set-ItemProperty $k -Name $n -Value $af
#				}
#				catch {
#					Log "ERROR: Could not set registry entry $k\$($n): $_" -level Error
#					return $false
#				}
#			}
#
#	return $true
#}
#
#


###########################################################################
# Get the installed Microsoft registry key value

function GetMicrosoftRegKeyValue([string]$PropertyName, [string]$SubKey)
{
  $basekey = "HKLM:\SOFTWARE\MicroSoft"
  $key = Join-Path $basekey $SubKey
  $val = (Get-ItemProperty $key -name $PropertyName -ErrorAction Ignore).$PropertyName
  if (-not $val) {
    $val = "error"
	}
	return $val
}


############################################################
# Write debug

function WriteHostDebug([string]$message)
{  
  $debug = GetConfigValue "ShellDebug"
  if ($debug -eq "true") {
    Write-Host "(debug) $message" -foregroundcolor "gray"
  }
}


############################################################
# Prompt the user to imput a value

function PromptForInput([string]$prompt, [string]$default)
{  
  # prompt for an input value
  Write-Host $prompt -foregroundcolor "white" -nonewline
  Write-Host " " -foregroundcolor "white" -nonewline
  $v = Read-Host
  if (!$v -and $default) {
    $v = $default
  }
  return $v
}

############################################################
# Prompt the user to imput a target

function PromptForTarget([string]$default)
{  
  # prompt for an input value
  Write-Host "New Target? ([quit,help,list], default: $default): " -foregroundcolor "yellow" -nonewline
  [string]$commandline = Read-Host
  if (!$commandline) {  
    $parameters = @( 1 )
    if ($default) { $parameters[0] = $default }
  } else {
    $parameters = $commandline.Split()
  }
  return [array]$parameters
}


###########################################################################
# Find target by name

function ShellFindTarget([string]$target)
{
  $moduleConfigs = $GlobalConfigSettings["__ModuleConfigs"]

	$found = $false
	foreach ($mc in $moduleConfigs) {
		foreach ($targetNode in $mc.Xml.Configuration.Target | ?{$_.Name -eq $target}) {
	    Write-Host ""		
			Write-Host "Found target in '$($mc.ConfigFile)'" -foregroundcolor "white"
	    Write-Host ""					
			$found = $true
		}
	}
	if (!$found) {
	  Write-Host ""
		Write-Host "Target '$target' not found" -foregroundcolor "yellow"
	  Write-Host ""		
		return $false
	}
	return $true
}
